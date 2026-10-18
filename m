Received: from mail-dy1-f169.google.com (mail-dy1-f169.google.com [74.125.82.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83BDD3D413C
	for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 11:33:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.82.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792323205; cv=none; b=n0k0zFhR9yihBYVzfT9XLIjJGpJof5mGBpKvMPB6AMcyqLUnhSbZBzxTY/DRW4f/RMPpDzlv3cKrMMOW4rsODcIdEpLGMFItvsaO8epKVuWct7KaIq8vVjrD2g94Jlohemg4S3pl6cyV10Q2VD/i8zuJPwLhPjRjNDbcnT6QFSs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792323205; c=relaxed/simple;
	bh=HQcatveyDyajpFL1UBpeC4RAkhS4VBszbXSkpzNqt7Q=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=tFyhrwmOZf4BUs+6ri9nPBglFarbyDzQ5FXCDjc4T34Fy/OO698mkwUj4YN2T2Zeabgs8fZIKsutlDDRDK9K7QNTIfbfkFEq0/P0fmI+Lg6O/k60FdioQudQNZf93Kuzkhw6E4bGrOnHIlQAcX/sf/xmsQsHMNvJOtkLVCeCRBI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=hwz2uCAJ; arc=none smtp.client-ip=74.125.82.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hwz2uCAJ"
Received: by mail-dy1-f169.google.com with SMTP id 5a478bee46e88-3282db206d3so1334452eec.0
        for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 04:33:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792323204; x=1792928004; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=yrG8DE2Q475ATUWi0QswHMnHOV5W49hUQct/k6+wgUg=;
        b=hwz2uCAJSTxVRK2UAzuYHQu/0eJccsXBoOllbMoSbCofj0IYYwWISteepMCgU1ev++
         d3utarnd0GuU5cvnFFAgessemGeMbhvglAx7ksSeANG6T9nevIkEYOUNQjTBYWgvLXgz
         t1AsILD16rMKddbpCEbH7dhbk7RyVAa6OKJ/lA6zI0FaJ8vth6ukokvK6jrJhOKLRSK/
         GlmjzWA8Mt/s/KsXgyPgsh9ZRosS/gj09XQsrQokWAbcs2pzJVdYtdmux1YS+uFG8zYM
         uF2pBkGMq1Ykpe5bD0VCo4sgQTT92BIo+e3SajJx9Q3EtKU8vc7lcdL8EIFHcrmFYSrq
         0EiQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792323204; x=1792928004;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=yrG8DE2Q475ATUWi0QswHMnHOV5W49hUQct/k6+wgUg=;
        b=qdB0x8coTcVU+wT2c9IcPZjrkUbdyvfB4zX+5ZIUGm6gGprR/yTgsLtUQI22VItgI/
         eP/ig9dpCC/O9bcepjx6jVygeMRyURoTUc8mULWBZDTlmz+kcFOOT9waJV+8hGFypEef
         XIs5Dcd/u+CG1v+tHY/lF2yrij6Yy4GDcq4EcpVbSxgtkXMl4kI0/ipoAAMOkuV9qWdO
         PBQZ1yFoUxWGSS5edhJXJddhzk7LCfcPmIERoFp391lB9BSlgcY9PmHbusoWMkY7nOFX
         /ztrt4W0OmIQ2RCv7AO7M7Zs2XSY5xLy1nYRZ99HOgA1Pf0GZoUZYKRpCBC4qnkYmxva
         SD3g==
X-Forwarded-Encrypted: i=1; AKwUvBxyua6qf3L+FzXfqXFHF52WRoZzVVFrskkv9WvkhnKEyryiM6YbL3VYB53q3VdISogzDVXgRBUpYDw=@vger.kernel.org
X-Gm-Message-State: AFq9FYJJStkMIos+czbJmLVZppHQayjo64LeHY5Hrp0GNvVDsnSZSJE6
	9E4ybxy5TEu0NcL1JyRUUc2Cy/0yLJwITfots4kYOY7j9sOntBhe+1lrZEa9jst8
X-Gm-Gg: AYBFou1qydlJWyOi5U8nyXyP9ugyw5z9DKnEOYHwPXRhCZXGxyAs+Gm8H1RhEcotJ5J
	XuHuESsf0JY2t31kGyf2CgrUZOP3NYrOg/6iNj2kbvkW2TrhP+b9QVmsPPF2IvATMY9wjzvgmnl
	trCS4h1318jpqGbjCLTuifUBDiIlZbpYKntDe4ZtF6U3nz6/B1Dx7E6CQKKyXdBjsgxVQIBt4G2
	y2nXiHnVLmp62XJW/iZdo+FNmssqqok486pt0sL7cF//jSLQU3ced+S2lmmokl14vHfIwa0Op/P
	M+oyNfQ0h7ThULuQqO7X3VMFWjDLmjbFRIzutkk90tLRN7Ot4kmaoqfHNUf10rYCuiukACtxiRV
	Ay4iYVKZ626Lj20NO0alVjLDetidnViShCHAdkg5+UKeR5hjVY2bA+ExeiTSC1SyX/QED75rnLh
	WS3GXxefgF2JRlwKo2wSfCgm5SgVwdrGeorZBHJ9T9RJpLxEZ80NDofsWNA5L/fqL4fdxcQezdk
	DfLiaEqmgo+RwhUPk93SdtuX/9RVLZaQs7kFOOpQRLWuxv49c8mYA5SlVjxnnqH
X-Received: by 2002:a05:7300:d10:b0:35a:84cc:d941 with SMTP id 5a478bee46e88-361a341c8e6mr9786894eec.37.1792323203533;
        Sun, 18 Oct 2026 04:33:23 -0700 (PDT)
Received: from deepanshu-Legion-Pro-5-16AFR10.. ([2405:201:682f:383f:a1f4:8b77:c28c:48f5])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-3607ee0cab0sm28859299eec.3.2026.10.18.04.33.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 18 Oct 2026 04:33:22 -0700 (PDT)
From: Deepanshu Kartikey <kartikey406@gmail.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: bfields@fieldses.org,
	skinsbursky@parallels.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Deepanshu Kartikey <kartikey406@gmail.com>,
	syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
Subject: [PATCH] nfsd: fix out-of-bounds read of sv_permsocks when starting a thread
Date: Sun, 18 Oct 2026 17:03:12 +0530
Message-ID: <20261018113312.10455-1-kartikey406@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd() derives its struct net from the first entry of
serv->sv_permsocks using list_entry() without checking that the list
is non-empty. If the list is empty, list_entry() returns a bogus
svc_xprt computed from the list head embedded in struct svc_serv, and
the following perm_sock->xpt_net load reads far past the end of the
svc_serv allocation:

  BUG: KASAN: slab-out-of-bounds in nfsd+0x118/0xbc0 fs/nfsd/nfssvc.c:894
  Read of size 8 at addr ffff88802d423f50 by task nfsd/5988

The list can be empty because nothing guarantees that a permanent
listener exists while a thread starts. With dynamic thread spawning, a
thread can begin running after the last listener has been closed and
removed.

Take sv_lock, which protects sv_permsocks, and check for an empty list
and read xpt_net in the same critical section. If there is no
permanent socket, report -ENOTCONN through svc_thread_init_status(),
which wakes the creator and exits the thread, instead of dereferencing
a bogus pointer.

Fixes: 88c476661719 ("nfsd: pass proper net to nfsd_destroy() from NFSd kthreads")
Reported-by: syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=561b859d032c8bf2fb53
Tested-by: syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
Signed-off-by: Deepanshu Kartikey <kartikey406@gmail.com>
---
 fs/nfsd/nfssvc.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2edf716ea022..da6fce79efae 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -890,17 +890,31 @@ nfsd(void *vrqstp)
 {
 	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
 	struct svc_pool *pool = rqstp->rq_pool;
-	struct svc_xprt *perm_sock = list_entry(rqstp->rq_server->sv_permsocks.next, typeof(struct svc_xprt), xpt_list);
-	struct net *net = perm_sock->xpt_net;
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct svc_serv *serv = rqstp->rq_server;
+	struct svc_xprt *perm_sock;
+	struct net *net = NULL;
+	struct nfsd_net *nn = NULL;
 	struct nfsd_thread_local_info ntli = { };
 	bool have_mutex = false;
+	int err = 0;
+
+	spin_lock_bh(&serv->sv_lock);
+	if (list_empty(&serv->sv_permsocks)) {
+		err = -ENOTCONN;
+	} else {
+		perm_sock = list_first_entry(&serv->sv_permsocks,
+					     struct svc_xprt, xpt_list);
+		net = perm_sock->xpt_net;
+	}
+	spin_unlock_bh(&serv->sv_lock);
 
+	if (!err)
+		nn = net_generic(net, nfsd_net_id);
 	/* At this point, the thread shares current->fs
 	 * with the init process. We need to create files with the
 	 * umask as defined by the client instead of init's umask.
 	 */
-	svc_thread_init_status(rqstp, unshare_fs_struct());
+	svc_thread_init_status(rqstp, err ?: unshare_fs_struct());
 
 	current->fs->umask = 0;
 
-- 
2.43.0

