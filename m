Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40642 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752571AbaHAQsr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Aug 2014 12:48:47 -0400
Date: Fri, 1 Aug 2014 12:48:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v3 21/38] nfsd: Add reference counting to state owners
Message-ID: <20140801164843.GB32749@fieldses.org>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
 <1406684083-19736-22-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406684083-19736-22-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 29, 2014 at 09:34:26PM -0400, Jeff Layton wrote:
>  struct nfs4_stateowner {
> -	struct list_head        so_strhash;   /* hash by op_name */
> -	struct list_head        so_stateids;
> -	struct nfs4_client *    so_client;
> +	struct list_head			so_strhash;
> +	struct list_head			so_stateids;
> +	struct nfs4_client			*so_client;
> +	const struct nfs4_stateowner_operations	*so_ops;
>  	/* after increment in ENCODE_SEQID_OP_TAIL, represents the next
>  	 * sequence id expected from the client: */

Uh, that could use updating--applying below.

Anyway, the stateowner reference counting makes sense to me.

--b.

commit 84a46922ea90
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Jul 31 16:10:08 2014 -0400

    nfsd4: fix out of date comment
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 73a209dc352b..0b234500f104 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -345,7 +345,7 @@ struct nfs4_stateowner {
 	struct list_head			so_stateids;
 	struct nfs4_client			*so_client;
 	const struct nfs4_stateowner_operations	*so_ops;
-	/* after increment in ENCODE_SEQID_OP_TAIL, represents the next
+	/* after increment in nfsd4_bump_seqid, represents the next
 	 * sequence id expected from the client: */
 	atomic_t				so_count;
 	u32					so_seqid;
