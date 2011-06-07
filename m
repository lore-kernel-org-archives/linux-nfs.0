Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52459 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756389Ab1FGBov (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jun 2011 21:44:51 -0400
Date: Mon, 6 Jun 2011 21:44:50 -0400
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: more pynfs tests
Message-ID: <20110607014450.GI1151@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Casey's been finding some delegation bugs, so I added a few more
delegation tests, all available from the master branch of

	git://linux-nfs.org/~bfields/pynfs.git

--b.

commit 89d04c11546fa5b73fc5d9fff985c848f13e35a7
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Jun 6 21:13:16 2011 -0400

    TESTS: test that RENAME over a file recalls a delegation
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit bc16acebfec0d18fd0290cafba640ffee652701b
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Jun 6 21:10:36 2011 -0400

    TESTS: test that RENAME recalls delegation
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 123281663c7845c9f2f10411cee969a4aa5a9ce4
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Jun 6 19:50:51 2011 -0400

    TESTS: test that LINK recalls delegation
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit d9059bc0dba5333a56387ec11a5d592a0d54af1a
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Jun 6 21:14:49 2011 -0400

    TESTS: don't wait as long on delegation tests
    
    I can't see the advantage of 5 second waits and exponential backoff.
    Normally this will be fast.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit be00fef805658b0d3ff889ab30fa51c976a3c1b2
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Jun 6 18:58:45 2011 -0400

    TESTS: factor out retry loop from DELEG15
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
