Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48804 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753020Ab2CBXOE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 18:14:04 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1S3bfn-0007O0-95
	for linux-nfs@vger.kernel.org; Fri, 02 Mar 2012 18:14:03 -0500
Date: Fri, 2 Mar 2012 18:14:03 -0500
To: linux-nfs@vger.kernel.org
Subject: pynfs reboot recovery updates
Message-ID: <20120302231402.GC26396@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'll stop sending all my pynfs changes to the list; they're available
at:

	git://linux-nfs.org/~bfields/pynfs.git

Most of these changes are to fix some reboot recovery tests, mainly 4.0
tests, but I also got the 4.1 tests updated and running.

I also modified by regular regression-test scripts to run the reboot
tests by default again (git://linux-nfs.org/~bfields/testd.git).  I'm
just stopping and starting the server instead of doing a full reboot, to
make them a bit less of a hassle to run.

Also some minor changes to reduce the 4.0/4.1 diff in a few cases, and
an extra close test; changes summarized below.

--b.

commit 56cb89202241fc6f5ff5a89fa7487c879ab6d4fc
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Mar 2 17:06:15 2012 -0500

    4.1 server tests: generalize reboot helper script
    
    This is just bdea95dea8e9656357db937560dbcb4af62e3926 for the 4.1 side.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 7d478ce2db5a9946b245684570f9b3d2755a6b1d
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Mar 2 15:20:21 2012 -0500

    4.0 server tests: fix a reboot typo

commit da8558fcad1c0b3debcd013189076e63224c6c81
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Mar 2 15:09:47 2012 -0500

    4.0 server tests: don't let client expire in REBT11
    
    REBT11 has the same problem as REBT3 (see
    0f1831a31124d677d711daee527ffa9d41a84c06).
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit c753542f55a18af2df33a899af516cfb050b1256
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Mar 2 14:32:47 2012 -0500

    4.0 server tests: 4.0 testserver.py updates from 4.1
    
    Miscellaneous (some trivial) changes to make testserver.py more similar
    between 4.0 and 4.1 cases.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 099cd623bf621727cd488484c484817c2f651677
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Mar 2 14:17:17 2012 -0500

    4.0 server tests: fix indent typo

commit eae978bc13e79e8999e5d998eb8a0694c20f9681
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Mar 2 14:11:52 2012 -0500

    testserver help file grammar fix
    
    1f130fa14e79ddfbf9a66da976fad7e8f68f2988 applies to 4.0 case as well.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit e22cc288abd8266cc2675382df1dae8f8f5e15e9
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Mar 2 14:10:42 2012 -0500

    Better error message when testserver gets socket error.
    
    Apply 26474d8e1453f9c134e7268e7f9ed14f524171e0 in 4.0 case as well.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    r On branch master

commit f5652e19ec9116b67848b68e58477b1d21f4c397
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Mar 2 13:43:14 2012 -0500

    4.0 server tests: require python 2.5
    
    Actually I have no idea what python version's really required, but we
    want to share more code here eventually so I'd rather take the higher
    requirement.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 6689197487298c7c521dfb178a4a52cf674a26db
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 1 17:15:25 2012 -0500

    4.0 server tests: REBT5,6 should expect BAD not CONFLICT
    
    The rfc 3530 language is rather skimpy.  Dave Noveck went into some more
    detail in a May 2009 message to the ietf list:
    
    	http://old.nabble.com/NFS4ERR_REC-LAIM_BAD-td23765973.html
    
    My understanding is that RECLAIM_BAD was originally intended for the
    case where a the reclaim does not match the server's stable storage
    information.  Whereas RECLAIM_CONFLICT would happen if e.g. a client's
    reclaim conflicts with a lock already reclaimed by another client on
    this boot cycle.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit c3af6b834a8d73afa94dfd1c2284c3661c9e60f7
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 1 16:51:00 2012 -0500

    4.0 server tests: remove incorrect REBT4
    
    The protocol does not require servers to remember individual opens.
    It's the client's responsibility to get this right.
    
    (Though it might be interesting to keep around a few optional tests like
    this for servers that do more bookkeeping.)
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 0f1831a31124d677d711daee527ffa9d41a84c06
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 1 16:46:48 2012 -0500

    4.0 server tests: don't let client expire in REBT3
    
    The wait after the post-reboot setclientid is long enough to allow the
    server to expire the client before we do the open, leading to spurious
    test failures with NFS4ER_EXPIRED.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 5fb95c35e6784b78767fea468cd18c34af905f51
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 1 15:46:48 2012 -0500

    more TODO's
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 497fc7bf844974e68f2956585275ed8960081f1e
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 1 15:46:48 2012 -0500

    TODO file
    
    Just some notes for myself.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 32be740af9e3d0daa6e3bb99488628ddb0adb78f
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 1 15:20:21 2012 -0500

    4.1 server tests: test close with stateid.seqid = 0
    
    Before f435d212d9553add548720975e720d7cd5ae8eba, pynfs used to do a
    close with stateid.seqid = 0 routinely in setup.  That seems the wrong
    place to do it, but it is supposed to work (and we have seen servers
    fail to do this), so we may as well have a test for it.
    
    Also, I mistakenly commented out that line in the previous fix when I
    meant to remove it completely.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
