Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60056 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750851Ab0HFEMH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Aug 2010 00:12:07 -0400
Message-ID: <4C5B8B48.4050008@cn.fujitsu.com>
Date: Fri, 06 Aug 2010 12:10:48 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] We should clear NFS_DELEGATED_STATE after return
 delegation
References: <4C592F85.8070308@cn.fujitsu.com>	 <4C59306A.9090302@cn.fujitsu.com>	 <1280925913.3011.23.camel@heimdal.trondhjem.org>	 <4C5A213F.9000506@cn.fujitsu.com> <1281013423.2948.1.camel@heimdal.trondhjem.org>
In-Reply-To: <1281013423.2948.1.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Trond Myklebust ŽÊ“¹:
> On Thu, 2010-08-05 at 10:26 +0800, Bian Naimeng wrote:
>>> On Wed, 2010-08-04 at 17:18 +0800, Bian Naimeng wrote:
>>>> We should clear NFS_DELEGATED_STATE bit for inode->open_states after return delegation.
>>>>

    ... snip ...

>>  Thanks Trond.
>>  But why we must remove test_and_clear_bit behind memcmp?
>>
>>  Always test_bit and memcmp have same result, and I think test_and_clear_bit is fast 
>>  than memcmp, so i suggest we should call test_and_clear_bit first. right?
> 
> We can't clear the bit before the memcmp() test. What we could do is
> keep the current test_bit() and then do a clear_bit after the memcmp().
> 

  When i apply the patch, my test still fail. 

   The ctx->state will set set after open success, but this ctx add to the
  the nfsi->open_files when we call nfs_open that is so early. So maybe
  there are some states can be found at nfsi->open_states, but not at
  ctx->state of nfsi->open_files, so we will miss clear NFS_DELEGATED_STATE
  for these state.

Regards
 Bian Naimeng

--------------------------------------------------

NFSv4: Remember to clear NFS_DELEGATED_STATE in nfs_delegation_claim_opens

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 fs/nfs/delegation.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 3016345..94a63e3 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -94,7 +94,7 @@ static int nfs_delegation_claim_opens(struct inode *inode, const nfs4_stateid *s
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
-	int err;
+	int err = 0;
 
 again:
 	spin_lock(&inode->i_lock);
@@ -112,12 +112,19 @@ again:
 		if (err >= 0)
 			err = nfs_delegation_claim_locks(ctx, state);
 		put_nfs_open_context(ctx);
-		if (err != 0)
-			return err;
+		if (err != 0) {
+			spin_lock(&inode->i_lock);
+			break;
+		}
 		goto again;
 	}
+
+	list_for_each_entry(state, &nfsi->open_states, inode_states) {
+		clear_bit(NFS_DELEGATED_STATE, &state->flags);
+	}
+
 	spin_unlock(&inode->i_lock);
-	return 0;
+	return err;
 }
 
 /*
-- 
1.6.5.2



-- 
Regards
Bian Naimeng

