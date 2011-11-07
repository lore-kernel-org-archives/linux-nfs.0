Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876Ab1KGU6W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 15:58:22 -0500
Message-ID: <1320699485.7987.9.camel@lade.trondhjem.org>
Subject: Re: regression in referrals resolution
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: tigran.mkrtchyan@desy.de
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Date: Mon, 07 Nov 2011 15:58:05 -0500
In-Reply-To: <CAGue13qcDxW9wFfuVuRnbZBcxuTWaXzW8CK1VFWj9483ardp0g@mail.gmail.com>
References: <CAGue13qcDxW9wFfuVuRnbZBcxuTWaXzW8CK1VFWj9483ardp0g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-11-07 at 21:29 +0100, Tigran Mkrtchyan wrote: 
> Hi,
> 
> 
> today we was running test with referrals and notice that 'current'
> 3.1+ has a regression.
> The referrals are resolved, but client returns IO error :

Doh! I expect that the following should fix it...

Thanks
  Trond
8<-------------------------------------------------------------------------- 
>From 91207dc6fd4fbe5f758dd2558e927bcd0c411581 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Mon, 7 Nov 2011 15:50:32 -0500
Subject: [PATCH] NFS: Fix a regression in the referral code

Fix a regression that was introduced by commit
0c2e53f11a6dae9e3af5f50f5ad0382e7c3e0cfa (NFS: Remove the unused
"lookupfh()" version of nfs4_proc_lookup()).

In the case where the lookup gets an NFS4ERR_MOVED, we want to return
the result of nfs4_get_referral(). Instead, that value is getting
clobbered by the call to nfs4_handle_exception()...

Reported-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 069cb80..be2bbac 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2464,8 +2464,7 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
 		case -NFS4ERR_BADNAME:
 			return -ENOENT;
 		case -NFS4ERR_MOVED:
-			err = nfs4_get_referral(dir, name, fattr, fhandle);
-			break;
+			return nfs4_get_referral(dir, name, fattr, fhandle);
 		case -NFS4ERR_WRONGSEC:
 			nfs_fixup_secinfo_attributes(fattr, fhandle);
 		}
-- 
1.7.7


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

