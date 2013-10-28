Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:40008 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757298Ab3J1Spw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 14:45:52 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/5] NFSv4: clean up nfs4_state reference counting
Date: Mon, 28 Oct 2013 18:45:50 +0000
Message-ID: <1382985949.3314.5.camel@leira.trondhjem.org>
References: <1382375414-5854-1-git-send-email-dros@netapp.com>
	 <1382375414-5854-6-git-send-email-dros@netapp.com>
In-Reply-To: <1382375414-5854-6-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-10-21 at 13:10 -0400, Weston Andros Adamson wrote:
+AD4- Use atomic+AF8-inc+AF8-not+AF8-zero() to avoid referencing a state that is currently
+AD4- being freed.
+AD4- 
+AD4- Signed-off-by: Weston Andros Adamson +ADw-dros+AEA-netapp.com+AD4-
+AD4- ---
+AD4-  fs/nfs/nfs4proc.c  +AHw- 8 +-+-+-+-+-+---
+AD4-  fs/nfs/nfs4state.c +AHw- 3 +-+--
+AD4-  2 files changed, 8 insertions(+-), 3 deletions(-)
+AD4- 
+AD4- diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
+AD4- index a3b78df..005543d 100644
+AD4- --- a/fs/nfs/nfs4proc.c
+AD4- +-+-+- b/fs/nfs/nfs4proc.c
+AD4- +AEAAQA- -1275,7 +-1275,8 +AEAAQA- static struct nfs4+AF8-state +ACo-nfs4+AF8-try+AF8-open+AF8-cached(struct nfs4+AF8-opendata +ACo-opendata)
+AD4-  out:
+AD4-  	return ERR+AF8-PTR(ret)+ADs-
+AD4-  out+AF8-return+AF8-state:
+AD4- -	atomic+AF8-inc(+ACY-state-+AD4-count)+ADs-
+AD4- +-	if (+ACE-atomic+AF8-inc+AF8-not+AF8-zero(+ACY-state-+AD4-count))
+AD4- +-		return ERR+AF8-PTR(-EINVAL)+ADs-
+AD4-  	return state+ADs-
+AD4-  +AH0-
+AD4-  
+AD4- +AEAAQA- -1429,7 +-1430,10 +AEAAQA- static struct nfs4+AF8-opendata +ACo-nfs4+AF8-open+AF8-recoverdata+AF8-alloc(struct nfs+AF8-open+AF8-context
+AD4-  	if (opendata +AD0APQ- NULL)
+AD4-  		return ERR+AF8-PTR(-ENOMEM)+ADs-
+AD4-  	opendata-+AD4-state +AD0- state+ADs-
+AD4- -	atomic+AF8-inc(+ACY-state-+AD4-count)+ADs-
+AD4- +-	if (+ACE-atomic+AF8-inc+AF8-not+AF8-zero(+ACY-state-+AD4-count)) +AHs-
+AD4- +-		nfs4+AF8-opendata+AF8-put(opendata)+ADs-
+AD4- +-		return ERR+AF8-PTR(-EINVAL)+ADs-
+AD4- +-	+AH0-
+AD4-  	return opendata+ADs-
+AD4-  +AH0-
+AD4-  
+AD4- diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
+AD4- index cc14cbb..1c71907 100644
+AD4- --- a/fs/nfs/nfs4state.c
+AD4- +-+-+- b/fs/nfs/nfs4state.c
+AD4- +AEAAQA- -1416,7 +-1416,8 +AEAAQA- restart:
+AD4-  			continue+ADs-
+AD4-  		if (state-+AD4-state +AD0APQ- 0)
+AD4-  			continue+ADs-
+AD4- -		atomic+AF8-inc(+ACY-state-+AD4-count)+ADs-
+AD4- +-		if (+ACE-atomic+AF8-inc+AF8-not+AF8-zero(+ACY-state-+AD4-count))
+AD4- +-			continue+ADs-
+AD4-  		spin+AF8-unlock(+ACY-sp-+AD4-so+AF8-lock)+ADs-
+AD4-  		status +AD0- ops-+AD4-recover+AF8-open(sp, state)+ADs-
+AD4-  		if (status +AD4APQ- 0) +AHs-

Is this patch needed? We should already be holding a reference to the
open+AF8-context, so AFAICS we know that the state-+AD4-count is non-zero.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
