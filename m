Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:50770 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753624Ab3J1VGI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 17:06:08 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/5] NFSv4: clean up state ref counting in open recover
Date: Mon, 28 Oct 2013 21:06:07 +0000
Message-ID: <1382994367.3314.7.camel@leira.trondhjem.org>
References: <1382375414-5854-1-git-send-email-dros@netapp.com>
	 <1382375414-5854-4-git-send-email-dros@netapp.com>
In-Reply-To: <1382375414-5854-4-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-10-21 at 13:10 -0400, Weston Andros Adamson wrote:
+AD4- There's already a valid state (the one being recovered), so just
+AD4- reference it. Also clean up error paths to avoid ref leaks.
+AD4- 
+AD4- Signed-off-by: Weston Andros Adamson +ADw-dros+AEA-netapp.com+AD4-
+AD4- ---
+AD4-  fs/nfs/nfs4proc.c +AHw- 13 +-+-+-+-+-+-+-+------
+AD4-  1 file changed, 8 insertions(+-), 5 deletions(-)
+AD4- 
+AD4- diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
+AD4- index 8140366..8ae1589 100644
+AD4- --- a/fs/nfs/nfs4proc.c
+AD4- +-+-+- b/fs/nfs/nfs4proc.c
+AD4- +AEAAQA- -1323,14 +-1323,14 +AEAAQA- +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state(struct nfs4+AF8-opendata +ACo-data)
+AD4-  		goto err+ADs-
+AD4-  	+AH0-
+AD4-  
+AD4- -	ret +AD0- -ENOMEM+ADs-
+AD4- -	state +AD0- nfs4+AF8-get+AF8-open+AF8-state(inode, data-+AD4-owner)+ADs-
+AD4- -	if (state +AD0APQ- NULL)
+AD4- +-	/+ACo- referenced the passed state +ACo-/
+AD4- +-	ret +AD0- -EINVAL+ADs-
+AD4- +-	if (state +AD0APQ- NULL +AHwAfA- +ACE-atomic+AF8-inc+AF8-not+AF8-zero(+ACY-state-+AD4-count))
+AD4-  		goto err+ADs-

We already know that state +ACEAPQ- NULL, and that state-+AD4-count +ACEAPQ- 0 here, so
I applied a simplified version of this patch that just does an
atomic+AF8-inc(+ACY-state-+AD4-count) just before the function return.

+AD4-  
+AD4-  	ret +AD0- nfs+AF8-refresh+AF8-inode(inode, +ACY-data-+AD4-f+AF8-attr)+ADs-
+AD4-  	if (ret)
+AD4- -		goto err+ADs-
+AD4- +-		goto err+AF8-put+ADs-
+AD4-  
+AD4-  	nfs+AF8-setsecurity(inode, +ACY-data-+AD4-f+AF8-attr, data-+AD4-f+AF8-label)+ADs-
+AD4-  
+AD4- +AEAAQA- -1340,9 +-1340,12 +AEAAQA- +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state(struct nfs4+AF8-opendata +ACo-data)
+AD4-  			    data-+AD4-o+AF8-arg.fmode)+ADs-
+AD4-  
+AD4-  	return state+ADs-
+AD4- +-
+AD4- +-err+AF8-put:
+AD4- +-	nfs4+AF8-put+AF8-open+AF8-state(state)+ADs-
+AD4- +-
+AD4-  err:
+AD4-  	return ERR+AF8-PTR(ret)+ADs-
+AD4- -
+AD4-  +AH0-
+AD4-  
+AD4-  static struct nfs4+AF8-state +ACo-

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
