Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52404 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728442AbeHWPwA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Aug 2018 11:52:00 -0400
Date: Thu, 23 Aug 2018 08:22:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 0/9] NFSD support for async COPY
Message-ID: <20180823122231.GA32415@fieldses.org>
References: <20180720221925.50744-1-kolga@netapp.com>
 <20180809203450.GE14104@parsley.fieldses.org>
 <20180823014722.GA24441@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180823014722.GA24441@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 22, 2018 at 09:47:22PM -0400, bfields wrote:
> Results are in my linux-next branch.

One more trivial change applied--this assignment seems unnecessary.

--b.

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a08f228cdf7..918cf63fd5d7 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1298,10 +1298,8 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		spin_unlock(&async_copy->cp_clp->async_lock);
 		wake_up_process(async_copy->copy_task);
 		status = nfs_ok;
-	} else {
-		copy->cp_synchronous = 1;
+	} else
 		status = nfsd4_do_copy(copy, 1);
-	}
 out:
 	return status;
 out_err:
