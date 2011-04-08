Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9939 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752946Ab1DHSkt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Apr 2011 14:40:49 -0400
Subject: [GIT PULL] please pull NFS client bugfixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 08 Apr 2011 11:40:47 -0700
Message-ID: <1302288047.15735.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/namespace.c                  |   58 +++++++++++++++--------------------
 fs/nfs/nfs4proc.c                   |    4 +--
 net/sunrpc/auth_gss/gss_krb5_mech.c |    2 +-
 3 files changed, 27 insertions(+), 37 deletions(-)

commit 37adb89fadd65ce47f7e5cfd564938a76b351948
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Thu Apr 7 16:02:20 2011 -0400

    NFS: Change initial mount authflavor only when server returns NFS4ERR_WRONGSEC
    
    When attempting an initial mount, we should only attempt other
    authflavors if AUTH_UNIX receives a NFS4ERR_WRONGSEC error.
    This allows other errors to be passed back to userspace programs.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 418875900e3de4831c84f86ae4756690dac5be77
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Wed Apr 6 14:33:28 2011 -0400

    NFS: Fix a signed vs. unsigned secinfo bug
    
    rpc_authflavor_t is cast from an unsigned int, but the
    initial code tried to use it as a signed int.  I fix
    this by passing an rpc_authflavor_t pointer around, and
    returning signed integers from functions.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Reported-by: Dan Carpenter <error27@gmail.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0867659fa3c245bf203d837a82e0f6ea5079c2c5
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Apr 6 10:13:32 2011 -0700

    Revert "net/sunrpc: Use static const char arrays"
    
    This reverts commit 411b5e05617593efebc06241dbc56f42150f2abe.
    
    Olga Kornievskaia reports:
    
    Problem: linux client mounting linux server using rc4-hmac-md5
    enctype. gssd fails with create a context after receiving a reply from
    the server.
    
    Diagnose: putting printout statements in the server kernel and
    kerberos libraries revealed that client and server derived different
    integrity keys.
    
    Server kernel code was at fault due the the commit
    
    [aglo@skydive linux-pnfs]$ git show 411b5e05617593efebc06241dbc56f42150f2abe
    
    Trond: The problem is that since it relies on virt_to_page(), you cannot
    call sg_set_buf() for data in the const section.
    
    Reported-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org	[2.6.36+]


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

