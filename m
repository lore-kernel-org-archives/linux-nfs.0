Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53286 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755486Ab3J1VIZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 17:08:25 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/5] NFSv4: don't reprocess cached open CLAIM_PREVIOUS
Date: Mon, 28 Oct 2013 21:08:24 +0000
Message-ID: <1382994502.3314.9.camel@leira.trondhjem.org>
References: <1382375414-5854-1-git-send-email-dros@netapp.com>
	 <1382375414-5854-5-git-send-email-dros@netapp.com>
In-Reply-To: <1382375414-5854-5-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-10-21 at 13:10 -0400, Weston Andros Adamson wrote:
+AD4- Cached opens have already been handled by +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state
+AD4- and can safely skip being reprocessed, but must still call update+AF8-open+AF8-stateid
+AD4- to make sure that all active fmodes are recovered.
+AD4- 
+AD4- Signed-off-by: Weston Andros Adamson +ADw-dros+AEA-netapp.com+AD4-
+AD4- ---
+AD4-  fs/nfs/nfs4proc.c +AHw- 17 +-+-+-+-+-+-+-+-+-+-+-+-+-----
+AD4-  1 file changed, 13 insertions(+-), 4 deletions(-)
+AD4- 
+AD4- diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
+AD4- index 8ae1589..a3b78df 100644
+AD4- --- a/fs/nfs/nfs4proc.c
+AD4- +-+-+- b/fs/nfs/nfs4proc.c
+AD4- +AEAAQA- -1315,12 +-1315,15 +AEAAQA- +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state(struct nfs4+AF8-opendata +ACo-data)
+AD4-  +AHs-
+AD4-  	struct inode +ACo-inode +AD0- data-+AD4-state-+AD4-inode+ADs-
+AD4-  	struct nfs4+AF8-state +ACo-state +AD0- data-+AD4-state+ADs-
+AD4- +-	bool cached+AF8-open +AD0- false+ADs-
+AD4-  	int ret+ADs-
+AD4-  
+AD4- -	/+ACo- allow cached opens (+ACE-rpc+AF8-done +ACYAJg- +ACE-rpc+AF8-status) +ACo-/
+AD4- -	if (+ACE-data-+AD4-rpc+AF8-done +ACYAJg- data-+AD4-rpc+AF8-status) +AHs-
+AD4- -		ret +AD0- data-+AD4-rpc+AF8-status+ADs-
+AD4- -		goto err+ADs-
+AD4- +-	if (+ACE-data-+AD4-rpc+AF8-done) +AHs-
+AD4- +-		if (data-+AD4-rpc+AF8-status) +AHs-
+AD4- +-			ret +AD0- data-+AD4-rpc+AF8-status+ADs-
+AD4- +-			goto err+ADs-
+AD4- +-		+AH0- else
+AD4- +-			cached+AF8-open +AD0- true+ADs-

This too was replaced by a simplified version. Once we get rid of the
state +AD0APQ- NULL check, we can just replace the above with a 'goto update'

+AD4-  	+AH0-
+AD4-  
+AD4-  	/+ACo- referenced the passed state +ACo-/
+AD4- +AEAAQA- -1328,6 +-1331,10 +AEAAQA- +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state(struct nfs4+AF8-opendata +ACo-data)
+AD4-  	if (state +AD0APQ- NULL +AHwAfA- +ACE-atomic+AF8-inc+AF8-not+AF8-zero(+ACY-state-+AD4-count))
+AD4-  		goto err+ADs-
+AD4-  
+AD4- +-	/+ACo- cached opens have already been processed +ACo-/
+AD4- +-	if (cached+AF8-open)
+AD4- +-		goto update+ADs-
+AD4- +-
+AD4-  	ret +AD0- nfs+AF8-refresh+AF8-inode(inode, +ACY-data-+AD4-f+AF8-attr)+ADs-
+AD4-  	if (ret)
+AD4-  		goto err+AF8-put+ADs-
+AD4- +AEAAQA- -1336,6 +-1343,8 +AEAAQA- +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state(struct nfs4+AF8-opendata +ACo-data)
+AD4-  
+AD4-  	if (data-+AD4-o+AF8-res.delegation+AF8-type +ACEAPQ- 0)
+AD4-  		nfs4+AF8-opendata+AF8-check+AF8-deleg(data, state)+ADs-
+AD4- +-
+AD4- +-update:
+AD4-  	update+AF8-open+AF8-stateid(state, +ACY-data-+AD4-o+AF8-res.stateid, NULL,
+AD4-  			    data-+AD4-o+AF8-arg.fmode)+ADs-
+AD4-  

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
