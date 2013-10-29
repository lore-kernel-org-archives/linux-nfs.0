Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f43.google.com ([74.125.82.43]:48493 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab3J2Jhh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 05:37:37 -0400
Received: by mail-wg0-f43.google.com with SMTP id b13so7957766wgh.10
        for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2013 02:37:36 -0700 (PDT)
Message-ID: <526F81DE.6060704@primarydata.com>
Date: Tue, 29 Oct 2013 11:37:34 +0200
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/7] delegation state fixes and cleanups for 3.13
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit c7342d3cf5d5677063cbc6341634ed8cea1b176f
Author: Benny Halevy <bhalevy@primarydata.com>
Date:   Tue Oct 15 17:07:31 2013 +0300

    nfsd4: fix recall_lock use in unhash_delegation

    Access to dp->dl_perclnt must be synchronized by the recall_lock

    Signed-off-by: Benny Halevy <bhalevy@primarydata.com>

commit 87174785bcec37371b718757af67dde0f6d083e3
Author: Benny Halevy <bhalevy@primarydata.com>
Date:   Tue Oct 15 17:29:13 2013 +0300

    nfsd4: need to destroy revoked delegations in destroy_client

    [use list_splice_init]
    Signed-off-by: Benny Halevy <bhalevy@primarydata.com>

commit 775a7353f9d1e60ebd9096b1a82bfb78fe7f3cc9
Author: Benny Halevy <bhalevy@primarydata.com>
Date:   Tue Oct 15 17:41:53 2013 +0300

    nfsd4: properly hash delegation in nfs4_setlease

    keep all accesses via dl_perclnt under the recall_lock.

    Signed-off-by: Benny Halevy <bhalevy@primarydata.com>

commit fdf586869a6b026893f818cb538574a7b77f5604
Author: Benny Halevy <bhalevy@primarydata.com>
Date:   Tue Oct 15 21:08:48 2013 +0300

    nfsd4: hash deleg stateid only on successful nfs4_set_delegation

    We don't want the stateid to be found in the hash table before the delegation
    is granted.

    Signed-off-by: Benny Halevy <bhalevy@primarydata.com>

commit 635a93446fde8d8fb1f4bb825926750d9b6aea9d
Author: Benny Halevy <bhalevy@primarydata.com>
Date:   Tue Oct 15 23:46:55 2013 +0300

    nfsd4: cleanup hash and unhash delegation

    make sure all atomic ops are under the recall_lock

    Signed-off-by: Benny Halevy <bhalevy@primarydata.com>

commit 39f26e5974f73b62144abde6793d41b07a32719a
Author: Benny Halevy <bhalevy@primarydata.com>
Date:   Tue Oct 15 23:50:30 2013 +0300

    nfsd4: move nfs4_put_file from unhash to put delegation

    revoked delegations are unhashed but are kept around in nfsv4.1	and we better
    hang on to dp_file in this case.

    Signed-off-by: Benny Halevy <bhalevy@primarydata.com>

commit cd2b2cac09cbd45419ce7d0e354dd94537a4fbfb
Author: Benny Halevy <bhalevy@primarydata.com>
Date:   Wed Oct 16 00:17:14 2013 +0300

    nfsd4: hold recall_lock while accessing nfs4_delegation.dl_recall_lru

    Signed-off-by: Benny Halevy <bhalevy@primarydata.com>

