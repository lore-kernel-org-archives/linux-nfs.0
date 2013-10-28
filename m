Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:45435 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992Ab3J1WO6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 18:14:58 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 3/5] SUNRPC: invalidate gss_context upon
 gss-ctx keyring key destruction
Date: Mon, 28 Oct 2013 22:14:56 +0000
Message-ID: <1382998486.3314.12.camel@leira.trondhjem.org>
References: <1382451676-2963-1-git-send-email-andros@netapp.com>
	 <1382451676-2963-4-git-send-email-andros@netapp.com>
In-Reply-To: <1382451676-2963-4-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-10-22 at 10:21 -0400, andros+AEA-netapp.com wrote:
+AD4- From: Andy Adamson +ADw-andros+AEA-netapp.com+AD4-
+AD4- 
+AD4- Lookup all gss+AF8-contexts matching the key-serial and set the
+AD4- gss+AF8-cred-+AD4-base (rpc+AF8-cred) cr+AF8-flags RPCAUTH+AF8-CRED+AF8-KEY+AF8-DESTROYED bit.
+AD4- 
+AD4- In gss+AF8-match, which is called prior to any use of the gss+AF8-cred,
+AD4- if the RPCAUTH+AF8-CRED+AF8-KEY+AF8-DESTROYED rpc+AF8-cred bit is set, return no match.
+AD4- 
+AD4- A future patch will make an exception, returning a match for any buffered
+AD4- writes setup before the RPCAUTH+AF8-CRED+AF8-KEY+AF8-DESTROYED flag was set.
+AD4- 
+AD4- When crmatch fails, the rpc code will then try to create a new
+AD4- gss+AF8-cred +- context, which will fail due to destroyed kerberos credentials.
+AD4- 
+AD4- Note: Currently we leave the RPCAUTH+AF8-CRED+AF8-KEY+AF8-DESTROYED cred in the
+AD4- unused lru list to be garbage collected.
+AD4- 
+AD4- Signed-off-by: Andy Adamson +ADw-andros+AEA-netapp.com+AD4-
+AD4- ---
+AD4-  include/linux/sunrpc/auth.h    +AHw-  1 +-
+AD4-  net/sunrpc/auth+AF8-gss/auth+AF8-gss.c +AHw- 45 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+--
+AD4-  2 files changed, 45 insertions(+-), 1 deletion(-)
+AD4- 
+AD4- diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
+AD4- index 790be14..f1151e3 100644
+AD4- --- a/include/linux/sunrpc/auth.h
+AD4- +-+-+- b/include/linux/sunrpc/auth.h
+AD4- +AEAAQA- -68,6 +-68,7 +AEAAQA- struct rpc+AF8-cred +AHs-
+AD4-  +ACM-define RPCAUTH+AF8-CRED+AF8-UPTODATE	1
+AD4-  +ACM-define RPCAUTH+AF8-CRED+AF8-HASHED	2
+AD4-  +ACM-define RPCAUTH+AF8-CRED+AF8-NEGATIVE	3
+AD4- +-+ACM-define RPCAUTH+AF8-CRED+AF8-KEY+AF8-DESTROYED 4
+AD4-  
+AD4-  +ACM-define RPCAUTH+AF8-CRED+AF8-MAGIC	0x0f4aa4f0
+AD4-  
+AD4- diff --git a/net/sunrpc/auth+AF8-gss/auth+AF8-gss.c b/net/sunrpc/auth+AF8-gss/auth+AF8-gss.c
+AD4- index 10d6e53..b7365b9 100644
+AD4- --- a/net/sunrpc/auth+AF8-gss/auth+AF8-gss.c
+AD4- +-+-+- b/net/sunrpc/auth+AF8-gss/auth+AF8-gss.c
+AD4- +AEAAQA- -115,12 +-115,52 +AEAAQA- static void gss+AF8-free+AF8-ctx(struct gss+AF8-cl+AF8-ctx +ACo-)+ADs-
+AD4-  static const struct rpc+AF8-pipe+AF8-ops gss+AF8-upcall+AF8-ops+AF8-v0+ADs-
+AD4-  static const struct rpc+AF8-pipe+AF8-ops gss+AF8-upcall+AF8-ops+AF8-v1+ADs-
+AD4-  
+AD4- +-/+ACoAKg-
+AD4- +- +ACo- The UID Kerberos credential has been destroyed. Search all gss+AF8-auth
+AD4- +- +ACo- credential caches and mark all UID gss+AF8-creds RPCAUTH+AF8-CRED+AF8-KEY+AF8-DESTROYED.
+AD4- +- +ACo-/
+AD4- +-static void
+AD4- +-gss+AF8-mark+AF8-cred+AF8-destroy(uid+AF8-t uid, key+AF8-serial+AF8-t serial)
+AD4- +-+AHs-
+AD4- +-	struct gss+AF8-auth +ACo-ga+ADs-
+AD4- +-	struct rpc+AF8-cred +ACo-cr+ADs-
+AD4- +-	struct gss+AF8-cred +ACo-gc+ADs-
+AD4- +-	struct auth+AF8-cred ac +AD0- +AHs-
+AD4- +-		.uid +AD0- uid,
+AD4- +-	+AH0AOw-
+AD4- +-	int i+ADs-
+AD4- +-
+AD4- +-	spin+AF8-lock(+ACY-gss+AF8-auth+AF8-hash+AF8-lock)+ADs-
+AD4- +-	hash+AF8-for+AF8-each(gss+AF8-auth+AF8-hash+AF8-table, i, ga, hash) +AHs-
+AD4- +-		/+ACo- check all supported pseudoflavors +ACo-/
+AD4- +-		if (ga-+AD4-rpc+AF8-auth.au+AF8-flavor +AD4- RPC+AF8-AUTH+AF8-MAXFLAVOR) +AHs-
+AD4- +-			cr +AD0- rpcauth+AF8-lookup+AF8-credcache(+ACY-ga-+AD4-rpc+AF8-auth, +ACY-ac, 0)+ADs-
+AD4- +-			if (IS+AF8-ERR(cr) +AHwAfA- cr +AD0APQ- NULL)
+AD4- +-				continue+ADs-
+AD4- +-			gc +AD0- container+AF8-of(cr, struct gss+AF8-cred, gc+AF8-base)+ADs-
+AD4- +-			if (gc-+AD4-gc+AF8-serial +AD0APQ- serial) +AHs-
+AD4- +-				set+AF8-bit(RPCAUTH+AF8-CRED+AF8-KEY+AF8-DESTROYED,
+AD4- +-					+ACY-cr-+AD4-cr+AF8-flags)+ADs-
+AD4- +-			+AH0-
+AD4- +-			put+AF8-rpccred(cr)+ADs- /+ACo- balance get in lookup credcache +ACo-/
+AD4- +-		+AH0-
+AD4- +-	+AH0-
+AD4- +-	spin+AF8-unlock(+ACY-gss+AF8-auth+AF8-hash+AF8-lock)+ADs-
+AD4- +-+AH0-
+AD4- +-
+AD4- +-static void
+AD4- +-gss+AF8-user+AF8-destroy(struct key +ACo-key)
+AD4- +-+AHs-
+AD4- +-	gss+AF8-mark+AF8-cred+AF8-destroy(key-+AD4-uid, key-+AD4-serial)+ADs-

This won't compile when CONFIG+AF8-USER+AF8-NS+AD0-y. key-+AD4-uid is of type kuid+AF8-t,
and not uid+AF8-t...


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
