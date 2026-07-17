Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 077D032E151
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262808; cv=none; b=LjYLobCLsVN4UVrAZ41VVVu47mlyIf/itWyMv4W9JfqKlCzNk3EhSX316nNQRQeePj2m3mRJ+aQyVgJcnoPxfjCF0pS+d8WzP/auppdxhN/uRamXZZzNVXe77LKmhUcHBaXw1GGzc1ZFev7JB96KVmb1ItNY9OYYn10mYBcu/MY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262808; c=relaxed/simple;
	bh=u2BqhWKtK+PI/r9ntQXsrzIIwjkVEF+2sulYlOglmIo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Dcbg+DlIPf0adRqBtErk0SSY3B9FZ2R/I0htstmSPXZBO47h4dZGP45QYoq5I68qrVdicO4xIcmT/0JwFDWVmAEk7WMiB5GfFvGbvkplyi7ne840W+m02FmEqfMbfwDmfVlztz9NKA8Hz7xl/150X6CnAxdVpJGpfekxdeVz8LA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Ola/XlM/; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=j8RBt/wv; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Ola/XlM/";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="j8RBt/wv"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 7B0597A011B;
	Fri, 17 Jul 2026 00:33:24 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Fri, 17 Jul 2026 00:33:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262804;
	 x=1784349204; bh=MlHWIAB+Vg/rvF60JF3VQ5y2kOaIWr2vhXlFGD4vEq0=; b=
	Ola/XlM/+5FOczR5/ruLGXD+SLdQ8NTJQF4CGa/4xj+4Siybn8n9v9UKFQJGmiqe
	roH9a6aEnkSoL0fATbwoEWMUwxAKVM46FpT26Unt1hLVD5RvdEp7+EB/N4oBUO3P
	WZVF5tQEBHUIXM1YjWNuUaWE5bTTGvL+U5bLId+h5c2Wb3QaMszEirREvyZ0ZDWX
	jTQQ3jdoY9APlCGicUXNWxar4UxEVr4GT5QHRDBdZld85/dWK/a/TM8Fw8Ozt4ya
	kEwshOSBCPI4bMHNNWIpvHLkHOIQbSuboJNEaLQKk7pNVOY2m3/KLEv7uIpzaX9x
	IJ1QYPe6fxtIYg5qlXnF2A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262804; x=1784349204; bh=M
	lHWIAB+Vg/rvF60JF3VQ5y2kOaIWr2vhXlFGD4vEq0=; b=j8RBt/wvEVmru8B3b
	NOoebal6w4ofqQ0oiJEuCs+KFa2+EeNKoA2xXIALQkL3cRC/PqQA3MCltoSmLQo5
	Xk5yVnPUzjXhNDvhjJiMKKxPZ074tr/jt0p2Bxfawy0Yem/dPJZMBhLNtumcUmfX
	G/1ZVwl9Yn+JNu6dkeU0LE3rOP5rRhsNFTmy6VFpso5mBuxxcsRNzysHZillpl8G
	LUngiVt37WOWQpAzz5E9BO4rVoMguslfvjzIJK8D+B8Aygu3zk/eMH0sk6ccXT+6
	lumhWL8iDL6+cPgHFP3oEk2Uyw3LhW0d5IQKesXzFZrRAnP2gAGPQQQtHXrEMzK+
	6wlxQ==
X-ME-Sender: <xms:lLBZahnJvOkLp8bazQ8EHMfqk15UAHcLKbeGGteMo90-VcMhs2oI1g>
    <xme:lLBZaghXiypvg5HGWkjZ0tFl876LhUSqxoHe2l8n13fJnbDUs57y-Oe8kYirRPu5Q
    O6fOiezDzO6OngDFHRAo1kgn89QiyPLhPe_0lWdvuyHQRI7Wg>
X-ME-Received: <xmr:lLBZaheZqMFh6vd7-fG6ka0Maa1sT2YWAMSwXzLapG7VgzdpsALPa-L83etRImdqADlQ67VS68cQG_SeEVyOt7gZAVKn9Js>
X-ME-Proxy-Cause: dmFkZTFf1QU68ccbCX8W2k8Y1nGREK2lfBZ8muLx/9jWiTseOaEvZ5XgO1veuwpDDLDOh8
    GTBUmiRJRPyTQkIt2BUTpACGqxcYNQqe9Tcjx6k+JMfW40TZxrio5AhHmqjioKB7znJTir
    ATb1v/hlECnvAs6heOVcOHOlHDBfVnNe9pooX5hb/po3RqsBkktpkbuLKQfQYMMzr+JzB9
    /njxHQoF8AY+jho0jMT1tubTiNoCuayOLJLgFmAfFIsropGRO+BVYqdpkyAIA5dLkXTXCV
    Ha4vNgb6VzTYvk/ZKP8hUsX7dik9VUXtlC+e2jQNq5KVv1wL7YMoKmhY7BOqudAWlfzyfH
    aEF3Cf+Bs54y/v21FcDb5cQTOawGIJ2fIGugDeI0sRcCrXvCjtIK/amFSOauZYWlCM2EFk
    DOupXT/79ov5O5wrpdiv40hQxRpDY/87g7mnm4HDow/UWEb2lpxECpALAelYKQlDVa+VS8
    4qHbx2TaV/buf1X2C7DncomXjSzoCh2VdCfUUadhfKYNCqKLKgHRzWj/TqjEuB2OCrNyWz
    bpy8l8BSxDHr1LUIWFSCqAcYO9fcohPVKMj84osLLNZpJfc2LgoBSxN+lVyOBv+QOj+QPm
    FOaSL6UnvaM+6I1wE2xSbbpXoXEfVxPVDtSnAr+a5oT6FhQ4GfOMma4c9Oxg
X-ME-Proxy: <xmx:lLBZaohIdeWTOuwrIjoraBQ8CpX1Lgtrd6fI4dBYj9UNHUsJ78h2Nw>
    <xmx:lLBZahzh70WXTftA2sXKrVF-VEBMOJ96Bz8UlM6UzygtGudp2T-NUQ>
    <xmx:lLBZasMfYqiy7cfSp88Zjr_NtUk2tP_XZMvTYHeobW3QavboZYit1A>
    <xmx:lLBZaqUuHUrbCo0zk_3Iel90MeL829uzP7ObLSr3GexKZxF-6Lj0ng>
    <xmx:lLBZanGT2B4QMsXEIw23azurlE-dGLflExR42LkKyyTEDZcDtuceor6C>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:22 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 07/18] nfsd: remove subtlety from nfsd4_create_file()
Date: Fri, 17 Jul 2026 14:31:05 +1000
Message-ID: <20260717043242.1865905-8-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717043242.1865905-1-neilb@ownmail.net>
References: <20260717043242.1865905-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfsd4_create_file() has a switch with cases for
NFS4_CREATE_EXCLUSIVE and NFS4_CREATE_EXCLUSIVE4_1 which are identical
except for one line which is marked "subtle" in both cases.

The difference boils down to a "goto".  For the EXCLUSIVE case the
target is "out:" which is after a setattr call.  For EXCLUSIVE4_1
the target is "set_attr:" which is the start of that setattr call.

In the EXCLUSIVE case 'attrs' will only contain the verifier.  Setting
these again is not harmful as discussed in the previous patch.  It will
also call commit_metadata().  In performance terms the cost of an extra
'commit' in the rare case of a replaying exclusive create is negligible.

So we can safely "goto setattr" in both cases and thus simplify the
code.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2b9fad28a9ef..a311810abfde 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -390,22 +390,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			status = nfserr_exist;
 			break;
 		case NFS4_CREATE_EXCLUSIVE:
-			if (inode_get_mtime_sec(d_inode(child)) == v_mtime &&
-			    inode_get_atime_sec(d_inode(child)) == v_atime &&
-			    d_inode(child)->i_size == 0) {
-				open->op_created = true;
-				break;		/* subtle */
-			}
-			status = nfserr_exist;
-			break;
 		case NFS4_CREATE_EXCLUSIVE4_1:
 			if (inode_get_mtime_sec(d_inode(child)) == v_mtime &&
 			    inode_get_atime_sec(d_inode(child)) == v_atime &&
 			    d_inode(child)->i_size == 0) {
 				open->op_created = true;
-				goto set_attr;	/* subtle */
+				goto set_attr;
 			}
 			status = nfserr_exist;
+			break;
 		}
 		goto out;
 	}
-- 
2.50.0.107.gf914562f5916.dirty

