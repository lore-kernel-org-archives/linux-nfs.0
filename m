Received: from mail-ot1-f48.google.com (mail-ot1-f48.google.com [209.85.210.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFFAC3D5222
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 22:29:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791498582; cv=none; b=fkt0tus4yC+2P8GopwaiXjmLt1oik0ijtNFJ7IbL79i6cvnorB6GDCuu+upQbvKBoZA7VUzfaZwLk453woDfi5C3fzuHf3A2vIUAxKUiwWDTtVHiLXOw8JWjyzXpBzgqeY91kXMJ5QhrEcX1B3x24cVLc7qavKqWKP95pyjmwq0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791498582; c=relaxed/simple;
	bh=MMkFjdCVMG5VlmQMbxTqaxCN0UUVNziiQoEjmEPy7OU=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=nrgyxp0nxQkv2XU+Ok/yhigKFRV3WkC9UCNLwZhNrPJdLynLcrpyGFBlmP02PoFCQkazfvSF21CKRTZ3baUC+4g8TC7oKplQh01Kf6PSQNGRxQxBIAwYaYFuS+e3Tsh4dihpLqCnAa0+edyGvsL7zUOV3vET1TtZJFs/qGV0yYw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=SEv++YOj; arc=none smtp.client-ip=209.85.210.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="SEv++YOj"
Received: by mail-ot1-f48.google.com with SMTP id 46e09a7af769-8266c388b67so3273179a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2026 15:29:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1791498580; x=1792103380; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=fXHi3/KeYOzGlvHrMQmcR6EwJ6rahH5N/eWTDsqU4mE=;
        b=SEv++YOjGdnJBoae3k3mlPlF/9U85SrdzPr3N7YUKNxZetcZ/YUr6PbThhhiyJPrJt
         IBl8BadskDdWUnXyTsSatWlESKmBSQrPyDuH38fqk3klduLd4+nGPoDhpzWi2hcIEhh3
         1PGeS6nT6VzfXUjuacWFYEuiwvNSbxveue2nGYvTDZPcmbtWiOKjt0B8FlWeofLer98f
         RWJsIH/KYkdIsdWPQ7mkCCYZcZ9BxZX/Ewb4d2srlHzOsH96GEGBzWF3AyBgG53sOH9M
         3gwve6+6NLi/Pp1Mg/7KvZ1cRW7jUQsHfoyf4ngZXitr3EaCqX4bTK9OOuDeIQiY87rn
         4MIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791498580; x=1792103380;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=fXHi3/KeYOzGlvHrMQmcR6EwJ6rahH5N/eWTDsqU4mE=;
        b=rcwddYrnkAjjcR05pMOrqPVu1LIH7MMnDlxZDIugLqCWeKTYKMFL3lVZ6Q8ivhtyZF
         GEgWVgHqxdb71yeb14gtOrI7eKr3/3eFRTSBHmqB2mBJsNGrLBwTWklKuvEddH7LSi/C
         DtXhQT3yqAfhatDetp7UCLU1n95wYQQkFk4Y8l8EpmRnoqXWDChqsAG0N0aIU0rMK5uR
         Y4Ti2MPuwm4hxw3MgvflvtCzbTQibPoM8imQnUCfKfKx9Pcv68CrBYmzlVdIB6d0qALB
         u7splGH9WZb5btFuCDKyn4yNqMUgnBgd5dTRUViGt8iWBA+y7AWrOmot0lLXIeTAX/kz
         uviw==
X-Gm-Message-State: AFuF++lMbx365iV1IFob1t8ANiCuZNyYE9IcuOoLgmO9OaTQ3dbgAn6M
	s9Q/xIEhXJpcf/nje/wpCMwWX2WMJIlP0QTxxdklz05inpzOa9YAqeOjMo2RMnADQrYK4nddTp7
	aoTSriKK4cHRP8YnJ6NA/7PnajpuBw9JZf/uEEUhHnwBbdRhaNb28I98IZQHF8HeGTm4AKGaUwO
	8GoC1tQu0V1iBjMZsQdwL7hJrJ8XAEn3GWUe6R7qUd8YW5DpmZPw==
X-Gm-Gg: AYBFou1JNcvVz/Gu78IgNE/4NuVz/LnFar/Uu/bgktd24fsHruusePQjMrGWjCN5uAc
	jb0fTdZm4tuF61FmsJzARmDKlktY7RCMp+0CkgX9VPA9ihsGZ2Ln7ipVmYMrjDqpcADWRR7euPS
	i0WttreKOqfbburUGmM0Y2ZLX5Z9b8oRhkWzSddt+M79ipplkpkpb2F+AiXopMZe0gKu0TP02Rj
	hK4GAYxiT3u+MO87CPaj1ae/aCOF1Gtii1y0ocUMqxBjPdWmHXh/9er5bySdI6xJhD4v2Fu1xht
	jJhedD181FYRKc6gf5yAX/y7TpH7vWteqiJNq8s33NHUlqrBNgKyhtCgEE5xPxP/oYBGlqkONnh
	yb+VFDmEsTq4UjnEuRhnBny2laEMo1TAK5l8vEBpb5oLorJSvBy6Fis8VKUeYd50HCl8BqMv4ZY
	IVf6i8XP2+l7HXEt3YdoTL/zYeigEBvk107WbB5qeGwuORP1pLqhfIcps/07rr5Yp62PKyUvW+Y
	72+iiy1dzyzew7rilPy39YfO2Z8Tnb2wyBG
X-Received: by 2002:a05:6830:410f:b0:81b:c6da:c351 with SMTP id 46e09a7af769-8302ae8089dmr414913a34.17.1791498579523;
        Thu, 08 Oct 2026 15:29:39 -0700 (PDT)
Received: from irdv-lubao.dev.purestorage.com ([208.88.158.129])
        by smtp.googlemail.com with ESMTPSA id 46e09a7af769-83038f82468sm278874a34.11.2026.10.08.15.29.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Oct 2026 15:29:38 -0700 (PDT)
From: Lucheng Bao <lubao@everpuredata.com>
To: linux-nfs@vger.kernel.org,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	tmenninger@everpuredata.com,
	jcurley@everpuredata.com,
	Lucheng Bao <lubao@everpuredata.com>,
	stable@vger.kernel.org
Subject: [PATCH 2/2] NFSv4/pNFS: defer LAYOUTRETURN after an unsuccessful OLD_STATEID refresh
Date: Thu,  8 Oct 2026 22:28:43 +0000
Message-Id: <20261008222843.63319-3-lubao@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20261008222843.63319-1-lubao@everpuredata.com>
References: <20261008222843.63319-1-lubao@everpuredata.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Commit c16467dc03db ("pnfs: Fix handling of NFS4ERR_OLD_STATEID replies
to layoutreturn") made stateid refresh fail while newer layout segments
remain busy. The standalone LAYOUTRETURN handler still treats this as a
completed return, potentially discarding a pending LAYOUTCOMMIT.

Set rpc_status to -EAGAIN before the existing completion handling so the
release callback defers the return for a live inode. Leave successful
refreshes and inode-teardown behavior unchanged.

On 6.8.0, this change applies without commit bbbff6d5edd1 ("NFSv4/pNFS:
Retry the layout return later in case of a timeout or reboot"), but that
commit and its prerequisites are required for the deferred-release
behavior.

Fixes: c16467dc03db ("pnfs: Fix handling of NFS4ERR_OLD_STATEID replies to layoutreturn")
Cc: stable@vger.kernel.org # See commit message for prerequisites
Signed-off-by: Lucheng Bao <lubao@everpuredata.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1ae047a062b8..9993e4d29d72 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9867,6 +9867,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 					&lrp->args.range,
 					lrp->args.inode))
 			goto out_restart;
+		lrp->rpc_status = -EAGAIN;
 		fallthrough;
 	default:
 		task->tk_status = 0;
-- 
2.34.1

