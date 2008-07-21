From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfs: return compound hdr.status when there are no op replies
Date: Mon, 21 Jul 2008 19:59:36 +0300
Message-ID: <1216659576-19011-1-git-send-email-bhalevy@panasas.com>
References: <1216159035.7981.70.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1216159035.7981.70.camel@localhost>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

When there are no op replies encoded in the comound reply
hdr.status still contains the overall status of the compound
rpc.  This can happen, e.g., when the server returns an
NFS4ERR_MINOR_VERS_MISMATCH error.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b916297..ac2386b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2222,6 +2222,8 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	hdr->tag = (char *)p;
 	p += XDR_QUADLEN(hdr->taglen);
 	READ32(hdr->nops);
+	if (unlikely(hdr->nops < 1))
+		return nfs4_stat_to_errno(hdr->status);
 	return 0;
 }
 
-- 
1.5.6.4
