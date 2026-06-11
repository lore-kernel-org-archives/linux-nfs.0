Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C43EB4C957B;
	Thu, 11 Jun 2026 17:51:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781200264; cv=none; b=t1Aw63jeFXIpDmYt7v7tFG7UpJBcRjDIsPAx/pxen+vdU4oeZDFIG5wM/6YxpBJJPuIuH5gfgHmVxA9Rb/gR5V5+XLsj3ng9ofXn7tfH5lLuuI7JDitBz689TzysHiOJGvLw9lJ3D8uWcI9MlZNBc7/Vlh4b2IOEWlplZB8hMHw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781200264; c=relaxed/simple;
	bh=Z9PQXxGT0Za/+E6J+7SEhVY5kT9xYRNXrypAbhZ6NSk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ajNNIfjme3CuGXEqqr6eRkJD7jyYs9sDOsGncGsdzoaZaT8QGjE05D1Or63LX6wtXLCm+5BoDP+WFEaD6dilpiVIpEzRx9f4OA1mzsoByO5xcXZ7WzxPhK3abLYc3zCn0gJ50DUGcTgSJcGfzFu/FdeK7Lz1BejaDmr5XRhkqDM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YrWXFqgR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YrWXFqgR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 077B71F00899;
	Thu, 11 Jun 2026 17:51:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781200262;
	bh=Aj4PloKil1ZVzC0RUAlqMUlsXH0YAb7CWvzBrJRFPj8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YrWXFqgR3Zu5zF75i6EROWhmb/0Wh/Ob9h38a2Rgc9d2UQX28LpzdRDPaImtNVq+R
	 PhrDc1n9BWlIajK2GCroBT1qp4cmHEp2zaEa0IXogD1cRXRz5reDfsgoMudHKaOc+I
	 HyeumlK7o2EcpQOJVX3JnSmMwuTkSI+2Gh3hDhJVvT69/PCPBLOQbXfJdE0VrUvEsw
	 Ht6MGPNkkJh3odEFgQQkLTl/rfbGxZfoTsd7oU9NdA/o8puo67wUab4/VbFHXBcyN8
	 Kk8+mkWOJiTlq3alzR2lNyrhVgcxu6TIr5bCilj6LuynaJB/3/BQKqwSUJvKA1FAM2
	 nFGHvNIwDkSFw==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 13:50:22 -0400
Subject: [PATCH v6 16/20] nfsd: add a fi_connectable flag to struct
 nfs4_file
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260611-dir-deleg-v6-16-4c45080e5f3f@kernel.org>
References: <20260611-dir-deleg-v6-0-4c45080e5f3f@kernel.org>
In-Reply-To: <20260611-dir-deleg-v6-0-4c45080e5f3f@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Chuck Lever <cel@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, 
 Alexander Aring <alex.aring@gmail.com>, Amir Goldstein <amir73il@gmail.com>, 
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, 
 Calum Mackay <calum.mackay@oracle.com>, linux-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1426; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Z9PQXxGT0Za/+E6J+7SEhVY5kT9xYRNXrypAbhZ6NSk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKvVkHJJ9LiOhD1hBMiYj0aqx44RMGJSPzu5lW
 gtxmbt8NROJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCair1ZAAKCRAADmhBGVaC
 FWqBD/sEtNE7sq0gkNRU0ZLqZpdxImrg9QvqecIvF97zxu0C0eM6BB77RWGRcGvDEwrrDHSWQBZ
 +DjP+TdNekLifpiY6SKWOB9+phicp2qyHrITBaWQH4w6dRkIdwpTaisFFvMBv5Lv3UsKOdEb4ps
 nCbyEGcC3vyBi38bRkHNjRuVk/FNJjWUVk+shFHiV8uDpThKZcvSfMM3eEfiSvvu0jLST7VZvun
 UPfahmSCa0RaSOQi9I+IJ/uTci4Q3syQOOyIED9Ye1acJ5ZdfU6WG5Ua4/chD58eFV6rO6tLQni
 TjMG4qwsDj03SwQNfLC98n39R8oDpTUfDif/edkUoPbXows9z+Uk+mnImlr8iFmb84PsuPE617P
 D418ZcbXu4zNrFOKHn6tji7C3Oeez37ZEzzNccR71wGTkcbQPBo+5NCHwqd3Ln2m1jL7pPrJ5mr
 mot8vHxtX9ZWxXdgKAHtNAoTKpetk/dawMg5vjNujqaJlgqoda8K67woZir3yfohJVYxg2AjPPr
 RGAAH54y0EtzUSmJ4WIKb1SgTj2y5W7zbupxcr3M0YAmu8st/w97ByMdDoT6EXh/Nx2VE7Wq+kX
 cBm1iu1jEcr2JIFWKqkQ/Bz0mGHLUh6xRQoaRahZpMGqVzEfzcsH/8AnAtDQp6KvLSeQcaiEhec
 51xLGKs6/GCPq3g==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

When encoding a filehandle for a CB_NOTIFY, there is no svc_export
available, but the server needs to know whether to encode a connectable
filehandle. Add a flag to the nfs4_file that tells whether the
svc_export under which a directory delegation was acquired has subtree
checking enabled, in which case it needs connectable filehandles.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 1 +
 fs/nfsd/state.h     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 513cbc1a583f..aa99783ce901 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5231,6 +5231,7 @@ static void nfsd4_file_init(const struct svc_fh *fh, struct nfs4_file *fp)
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
 	fp->fi_aliased = false;
 	fp->fi_inode = d_inode(fh->fh_dentry);
+	fp->fi_connectable = !(fh->fh_export->ex_flags & NFSEXP_NOSUBTREECHECK);
 #ifdef CONFIG_NFSD_PNFS
 	INIT_LIST_HEAD(&fp->fi_lo_states);
 	atomic_set(&fp->fi_lo_recalls, 0);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f8457e0f2b57..d912e3d04dd7 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -761,6 +761,7 @@ struct nfs4_file {
 	int			fi_delegees;
 	struct knfsd_fh		fi_fhandle;
 	bool			fi_had_conflict;
+	bool			fi_connectable;
 #ifdef CONFIG_NFSD_PNFS
 	struct list_head	fi_lo_states;
 	atomic_t		fi_lo_recalls;

-- 
2.54.0

