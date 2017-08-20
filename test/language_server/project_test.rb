require 'test_helper'

module LanguageServer
  class ProjectTest < Minitest::Test
    def test_const_within_class_and_module
      store = FileStore.new
      store.cache('file:///a.rb', <<-EOS.strip_heredoc)
        class A
          module A
            class C
            end
          end
        end
      EOS

      store.cache('file:///b.rb', <<-EOS.strip_heredoc)
        class A
          module B
          end
        end
      EOS

      store.cache('file:///c.rb', <<-EOS.strip_heredoc)
        class B
          module C
          end
        end
      EOS

      uri = 'file:///foo.rb'
      store.cache(uri, <<-EOS.strip_heredoc)

        class A
          module A
            def hi
            end
          end
        end
      EOS

      project = Project.new(store)
      assert { project.modules(uri: uri, line: 0, character: 0).map(&:full_name) == [] }
      assert { project.modules(uri: uri, line: 1, character: 0).map(&:full_name).uniq.sort == %w(A::A A::B).sort }

      assert { project.classes(uri: uri, line: 0, character: 0).map(&:full_name).uniq.sort == %w(A B).sort }
      assert { project.classes(uri: uri, line: 1, character: 0).map(&:full_name).uniq.sort == %w(A B).sort }
      assert { project.classes(uri: uri, line: 2, character: 0).map(&:full_name).uniq.sort == %w(A B A::A::C).sort }
    end
  end
end
