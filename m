Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16682 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189Ab1JZHU3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Oct 2011 03:20:29 -0400
Date: Wed, 26 Oct 2011 01:30:34 +0200
Subject: Re: [PATCH] NFS/sunrpc: don't use a credential with extra groups.
Content-Type: text/plain;
	charset="utf-8"
Message-ID: <00de01cc93af$bc3812cc$d25f630a@hq.netapp.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "NeilBrown" <neilb@suse.de>, "NFS" <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil

I queued this patch up for linux-next testing earlier this morning. I could have included it in the pull I sent to Linus, but I'm trying to be a bit more strict about integration testing prior to pushing.

I also added a Cc: stable@kernel.org. I'm assuming that was appropriate.

Cheers
   Trond 

NeilBrown <neilb@suse.de> wrote:


Hi Trond,
 A customer hit this bug recently - which seems to have been around forever -
 at least since 2.6.16.

 I suspect few people would risk hitting it, but our customer does
 interesting things with group lists (presumably some least-privilege policy)
 and they managed to trigger it for us.

NeilBrown



>From 80b7771c0e18f755a6b9679e6c3b9d1449ba40ee Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Tue, 25 Oct 2011 10:17:06 +1100
Subject: [PATCH] NFS/sunrpc: don't use a credential with extra groups.

The sunrpc layer keeps a cache of recently used credentials and
'unx_match' is used to find the credential which matches the current
process.

However unx_match allows a match when the cached credential has extra
groups at the end of uc_gids list which are not in the process group list.

So if a process with a list of (say) 4 group accesses a file and gains
access because of the last group in the list, then another process
with the same uid and gid, and a gid list being the first tree of the
gids of the original process tries to access the file, it will be
granted access even though it shouldn't as the wrong rpc credential
will be used.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/auth_unix.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 4cb70dc..e50502d 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -129,6 +129,9 @@ unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
 	for (i = 0; i < groups ; i++)
 		if (cred->uc_gids[i] != GROUP_AT(acred->group_info, i))
 			return 0;
+	if (groups < NFS_NGROUPS &&
+	    cred->uc_gids[groups] != NOGROUP)
+		return 0;
 	return 1;
 }
 
-- 
1.7.7

