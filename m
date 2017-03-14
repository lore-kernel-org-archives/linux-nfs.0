Return-Path: <chuck.lever@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: git "make test" fails in t9200-git-cvsexportcommit.sh
Date: Tue, 14 Mar 2017 11:07:43 -0400
Message-Id: <12A85CA0-A715-4379-81D5-58A9CB001266@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Benjamin Coddington <bcodding@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben!

After addressing some IB stack issues that arose in v4.11-rc1,
I was finally able to run my standard suite of NFS tests with
v4.11-rc2. I found that part of the git regression suite fails
with this kernel.

Initially I start simply with NFSv3 and a tmpfs export. To
prepare for the test, my script does something like this:

$ cd /mnt/server
$ tar zxf ~/Downloads/git-2.3.7.tgz
$ cd git
$ make clean
$ make
$ cd t

Then, by hand:

    [cel@manet t]$ ./t9200-git-cvsexportcommit.sh
    ok 1 - New file
    ok 2 - Remove two files, add two and update two
    ok 3 - Fail to change binary more than one generation old
    ok 4 - Remove only binary files
    ok 5 - Remove only a text file
    ok 6 - New file with spaces in file name
    ok 7 - Update file with spaces in file name
    ok 8 - File with non-ascii file name
    ok 9 - Mismatching patch should fail
    ok 10 - Retain execute bit
    ok 11 - -w option should work with relative GIT_DIR
    ok 12 - check files before directories
    not ok 13 - re-commit a removed filename which remains in CVS attic
    #
    #
    #       (cd "$CVSWORK" &&
    #        echo >attic_gremlin &&
    #        cvs -Q add attic_gremlin &&
    #        cvs -Q ci -m "added attic_gremlin" &&
    #        rm attic_gremlin &&
    #        cvs -Q rm attic_gremlin &&
    #        cvs -Q ci -m "removed attic_gremlin") &&
    #
    #       echo > attic_gremlin &&
    #       git add attic_gremlin &&
    #       git commit -m "Added attic_gremlin" &&
    #           git cvsexportcommit -w "$CVSWORK" -c HEAD &&
    #       (cd "$CVSWORK"; cvs -Q update -d) &&
    #       test -f "$CVSWORK/attic_gremlin"
    #
    not ok 14 - commit a file with leading spaces in the name
    #
    #
    #           echo space > " space" &&
    #           git add " space" &&
    #           git commit -m "Add a file with a leading space" &&
    #           id=3D$(git rev-parse HEAD) &&
    #           git cvsexportcommit -w "$CVSWORK" -c $id &&
    #           check_entries "$CVSWORK" " =
space/1.1/|DS/1.1/|attic_gremlin/1.3/|release-notes/1.2/" &&
    #           test_cmp "$CVSWORK/ space" " space"
    #
    #
    ok 15 - use the same checkout for Git and CVS
    # failed 2 among 15 test(s)
    1..15
    [cel@manet t]$

A wire capture shows that some GETATTR operations receive
an NFS3ERR_STALE response from the server. I looked at one
of these, and it's against a renamed file "index.lock".

So I reverted:

commit 920b4530fb80430ff30ef83efe21ba1fa5623731
Author:     Benjamin Coddington <bcodding@redhat.com>
Date: Wed Feb 1 00:00:07 2017 -0500

NFS: nfs_rename() handle -ERESTARTSYS dentry left behind

And t9200 now passes:

    [cel@manet t]$ ./t9200-git-cvsexportcommit.sh=20
    ok 1 - New file
    ok 2 - Remove two files, add two and update two
    ok 3 - Fail to change binary more than one generation old
    ok 4 - Remove only binary files
    ok 5 - Remove only a text file
    ok 6 - New file with spaces in file name
    ok 7 - Update file with spaces in file name
    ok 8 - File with non-ascii file name
    ok 9 - Mismatching patch should fail
    ok 10 - Retain execute bit
    ok 11 - -w option should work with relative GIT_DIR
    ok 12 - check files before directories
    ok 13 - re-commit a removed filename which remains in CVS attic
    ok 14 - commit a file with leading spaces in the name
    ok 15 - use the same checkout for Git and CVS
    # passed all 15 test(s)
    1..15
    [cel@manet t]$

Wire capture shows no NFS3ERR_STALE results on the wire
during the successful test run.


--
Chuck Lever
