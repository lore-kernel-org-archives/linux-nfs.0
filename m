Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32786 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755596Ab1C2DSF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Mar 2011 23:18:05 -0400
Date: Mon, 28 Mar 2011 23:18:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd4: set right access bmap when initializing lock
 stateid
Message-ID: <20110329031804.GD2695@fieldses.org>
References: <4D90357D.3080604@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D90357D.3080604@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 28, 2011 at 03:15:09PM +0800, Mi Jinlong wrote:
>  
> Content-Type: text/plain; charset=ISO-2022-JP
> Content-Transfer-Encoding: 7bit

Thanks, Mi Jinlong, the analysis is helpful, but I don't think your fix
is right.

I think the problem here is basically that the cleanup on exit from
nfsd4_lock() may have to deal with a lock stateid that is partially
initialized, in that everything has been setup except the stuff that's
done by get_lock_access().

Maybe something like this??  But I'm not able to test right now.

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fbde6f7..9e8ef31 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -397,10 +397,13 @@ static void unhash_generic_stateid(struct nfs4_stateid *stp)
 
 static void free_generic_stateid(struct nfs4_stateid *stp)
 {
-	int oflag = nfs4_access_bmap_to_omode(stp);
+	int oflag;
 
-	nfs4_file_put_access(stp->st_file, oflag);
-	put_nfs4_file(stp->st_file);
+	if (stp->st_access_bmap) {
+		nfs4_access_bmap_to_omode(stp);
+		nfs4_file_put_access(stp->st_file, oflag);
+		put_nfs4_file(stp->st_file);
+	}
 	kmem_cache_free(stateid_slab, stp);
 }
 
