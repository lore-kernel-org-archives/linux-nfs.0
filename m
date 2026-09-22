Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1767047CA95;
	Tue, 22 Sep 2026 11:34:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790076863; cv=none; b=KqsVqvhoqhHkbTH9Oq2DTYTofchFvuDqRQWVPpD9LLyhcWOEVJHLAZiWWGfnUgXdh/AbizOvWaahkIjZUwDRmDURQJDxSX3I09N7QRAO/IGWwo85YnXZjKOWs80Pd6KHFS+u3FjtUCQCrGe/FcBKTeh04w4JCELGlnq5yQil+Qk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790076863; c=relaxed/simple;
	bh=ImZu2rrTp3BgaUjvgrhT8+XgUZVUh9pI+IzGxU0cFQ8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=FFn4MTvXAoZZJPWjLno9/JBjJ1gzd5e8YlOeokLts1++x7fC8Imb/xhhRx/HQnNJVshXcnpeBpAki61GSR+Rtav/gCC/C23EcjqAqj8Ki3XuB0Uik40gsEOdEWYTOr9rvHbhipUjNW058ZqH9QcFLBliB5SpejIpv13yi6n39GM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AFnk/Gff; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AFnk/Gff"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B6891F00898;
	Tue, 22 Sep 2026 11:34:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790076861;
	bh=LsBdDva0KrdXCVvAA86ZG5+kA6vb0RfnH5D+cyesTgw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=AFnk/GffxQ7fk6dYKEbnD1VVzyhd4LN/JNK/WaqMCPNS5DnESrdK5YKjmapjLPHJr
	 auybBiDR4P09oGAIpeU1dSmqwMKm7MFLIgW83yUI5ss/1TxYbLwAkaurBA/Xq89kq3
	 D1y3Ayeij10igSB4fasuqbGxnf71biRrj4Kdj4eJX2QvY7gItevlYtw5OJy8FTeVBI
	 +7YgeVDOctdmX48ngGXIV3Hlw8HB+pf1K9zF+d9IT3Otfk4qMd8k8rwA4zPzbFgqUf
	 kGo4CLeH4G9pKdKCQJrkZ4K4dWtJUaR7+TQTdHSH7yVFqAXLyYpGIFRMF2eVCl6uPf
	 Io3ro5/3JpG1g==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 22 Sep 2026 07:34:03 -0400
Subject: [PATCH v2 2/8] nfsd: make max_blksize a per-namespace setting
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260922-nfsd-per-net-mutex-v2-2-4a5da8243a73@kernel.org>
References: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
In-Reply-To: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3112; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ImZu2rrTp3BgaUjvgrhT8+XgUZVUh9pI+IzGxU0cFQ8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsme4X9HBu2mmnhbrrA8HOPjrhGAmRdUpIB1R2
 2GS6zffUjOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarJnuAAKCRAADmhBGVaC
 Fd/mEADIbLTXkkdy7b8rjk+6j854vsPUNN8dMFng7Quz8xPCs/PsCeDJD5HEXC7/LlrmF0fcYoq
 0UbKmjKrUx93yTwu/qYT3Ki5fRN/7T8Z7P5e9tU4zIhWZOXz/LMS91dY7sq20aNfL6NVwEW9wYb
 geigzwLPplOULxAu1wLaTn/1Cc/xT3Jy5kT+7zv92ZhJu7O64Q5Gb0kbgIhrXasEra3lSZVFJJc
 +qQUecmB4R+XHMSvK0c3KN9Nxwuqgne78iAmQKIk7qsCga3NJnHIf1FK9rh2B+3BcywdKqdSW5+
 Duz1eve01bP548EH11At7ynJ7Pe+m47s6n3MEI4+FZWIGkYtsslclLk5dzKDz3e/DoUc4VUJF0q
 36bm9M3ZmAFmD4HHkGVB1Sfgj2nva+r03iSnFi19b5PwDIR1/otAAerdr+5pcrJBCX1ESztY0Vm
 ymVeh+CzYdkezAHNTsqEt8FcCuD9xizrG/sUoubSlzrxqirHBt67ROjelU0FS6/ODp1tOnZuxmS
 pTOfo0KzIqVazOYIg8368fKPv4suLfT4iOw5yUoNpH1kK7EQcFlo9RIWkGBODNTkXsN0tthxp/+
 +N5zI+L2mVltr8huXlPK4CA3ePjXVD4reARFpbXeQRd2DwUVcRrH5sz2eeHvBtZIX4Jok/ITpOV
 p5haoA9MjvAmWZw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_max_blksize is module-scope, but /proc/fs/nfsd/max_block_size is a
per-netns file. A container writing it therefore changes the payload size
that every other namespace's next server start will use.

Move it into struct nfsd_net as ->max_blksize. The lazy
nfsd_get_default_max_blksize() fill-in now happens per namespace on first
nfsd_create_serv().

User-visible change: max_block_size no longer leaks across namespaces.

Fixes: 11f779421a39 ("nfsd: containerize NFSd filesystem")
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/netns.h  | 6 ++++++
 fs/nfsd/nfsctl.c | 8 +++-----
 fs/nfsd/nfsd.h   | 2 --
 fs/nfsd/nfssvc.c | 6 +++---
 4 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 0ce7da20aba3..374ce83e2ba0 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -154,6 +154,12 @@ struct nfsd_net {
 	 */
 	unsigned int min_threads;
 
+	/*
+	 * Maximum size of an NFS READ or WRITE payload.  Zero until the
+	 * first server start in this namespace picks a default.
+	 */
+	unsigned int max_blksize;
+
 	u32 clientid_base;
 	u32 clientid_counter;
 	u32 clverifier_counter;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f32311f2d7cf..330d0f12e199 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -885,8 +885,6 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 }
 
 
-int nfsd_max_blksize;
-
 /*
  * write_maxblksize - Set or report the current NFS blksize
  *
@@ -931,12 +929,12 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 			mutex_unlock(&nfsd_mutex);
 			return -EBUSY;
 		}
-		nfsd_max_blksize = bsize;
+		nn->max_blksize = bsize;
 		mutex_unlock(&nfsd_mutex);
 	}
 
-	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
-							nfsd_max_blksize);
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%u\n",
+							nn->max_blksize);
 }
 
 #ifdef CONFIG_NFSD_V4
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index d1e413d21e76..0864d6d564e2 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -143,8 +143,6 @@ enum {
 extern u64 nfsd_io_cache_read __read_mostly;
 extern u64 nfsd_io_cache_write __read_mostly;
 
-extern int nfsd_max_blksize;
-
 bool nfsd_v4client(struct svc_rqst *rqstp);
 
 /*
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d75fe1523436..77e1e6ba686d 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -630,12 +630,12 @@ int nfsd_create_serv(struct net *net, bool no_rpcbind)
 	init_completion(&nn->nfsd_net_free_done);
 	init_completion(&nn->nfsd_net_confirm_done);
 
-	if (nfsd_max_blksize == 0)
-		nfsd_max_blksize = nfsd_get_default_max_blksize();
+	if (nn->max_blksize == 0)
+		nn->max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions(nn);
 	serv = svc_create_pooled(nfsd_programs, ARRAY_SIZE(nfsd_programs),
 				 &nn->nfsd_svcstats,
-				 nfsd_max_blksize, nfsd);
+				 nn->max_blksize, nfsd);
 	if (serv == NULL) {
 		percpu_ref_exit(&nn->nfsd_net_ref);
 		return -ENOMEM;

-- 
2.55.0

