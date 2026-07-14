Received: from mail-pl1-f172.google.com (mail-pl1-f172.google.com [209.85.214.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F3804D8D9E
	for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2026 16:39:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784047195; cv=none; b=s1A1sAlloWZ/j5PK7VKOQpTenYgL+TZ3mlTJQw2KcY4S+uU58ukRnfcTtjjAMMCrpdoyRz8XaQs1/NjTpbrYvuSMHRI0OV0R/EdJJgwcEKNzzu0IqqoX6ojVahUNzMiPBrRDI8A5rir/c6LZenY/nhmExBp5WF+bLAcwMZPC5eg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784047195; c=relaxed/simple;
	bh=w1ayaFiykhXyStq+Fz4dl2B99MS+jLMfiGovaQyDklQ=;
	h=Subject:From:To:Cc:Date:Message-ID:MIME-Version:Content-Type; b=Q9NgkeiBY1oIY0EfpFfoNvqSmAvYsJCcoY2F0Nf6nlJRESqCfIYNt6Mfnqh+HE6+yYhFOLOYQy6bQu99fUKXjINcOi5G1t4ccGm1VIm1onqyuLyehHt42N2QvDtI4icnnAzEMric6386dA0lzp4dZCvwmBpqw6ffdkwqF5zKKUQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=PONAYks2; arc=none smtp.client-ip=209.85.214.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PONAYks2"
Received: by mail-pl1-f172.google.com with SMTP id d9443c01a7336-2c7c61b5292so17716555ad.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2026 09:39:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1784047194; x=1784651994; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:user-agent
         :message-id:date:cc:to:from:subject:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=fSSdPKad7upGTshmAAVeCJsnuIRzn7WTT52NBuduyY8=;
        b=PONAYks2e4EZa1wYDAQqw4VOzmCfYY6yQyQYF1UKRQoNsYfSIT82Hz9JxnxbVuMMzm
         3r04lUvB6/B7d8/t+4qqsmwi2tmVKXw0FT/brVhBs9PgBGnbtc4o7Oj6bWtW+qCfbbK1
         AdGLkJi4We95hr5Fov+SKTrdeSgngSFqCfkWCGFePEblaMPowepj7o0w6zpxnyhWu1fh
         1MyLoQIa2ugrP0J347YOYzfXTDa7M3Vz7jDEEFnV1sb6ivArGRv8xlTRxY0fxBsijkOQ
         vHZKRQ3YWNun6sMo5+biGkRlkW/9hC7SQ5o2/NRb/fFnQbt9nTB25ZZw/R5uP0RAVnN2
         8hUg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784047194; x=1784651994;
        h=content-transfer-encoding:content-type:mime-version:user-agent
         :message-id:date:cc:to:from:subject:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=fSSdPKad7upGTshmAAVeCJsnuIRzn7WTT52NBuduyY8=;
        b=VFUSYNqnrSvvHXeNg6BkOcwhVI1r+/Soxue/isyGHauGz5A8ljDxsFjxZq/Q2NDCJc
         5gH5Ii2/yKA+eh2sb1sQbVivU2GIBfZIUvm3tt53zaSqg3wSfS66QGGl2mtdX//SNRQV
         4ZGzZcqIX8rP2+fXiVzEkPCY0Q3nQuOoQqaDsL5AwK8jWiZI5FOkqLCmgcRlyFo/tViM
         cth9RCpZW3IdCmS5HHwgu63guJaHzQlPCH6mvKLxQj1Ob6N3YqpjHM/42kuh1DfZqqR4
         xpC+ura7kUXlLQ/2ar/UAaC46yI+6mLEu/UzfFEg5o0XAgFjfb/bdmM7tRfwJT0Lbrjx
         8+CQ==
X-Forwarded-Encrypted: i=1; AHgh+RrX842WgJcm08bAhvoP469ZGIfF5wqmBzxJSrxRr4bDdrA3sCUGW0z850FwBpMKIMTu+dLjmWztM3M=@vger.kernel.org
X-Gm-Message-State: AOJu0YwWB56UynblVFjNIJU80/uBRhwIhnNMf+3Xf9OkDak5qWe6Ml2i
	48IZkdm/tEIfVJjzLKsPk+5DnsF+YXsHHzseE6GR7P/1IzG6Cylx2BhKiXxGQKvX
X-Gm-Gg: AfdE7cme+yg08cxSQXnrkytFGJu5LFqEl5IlU0p2/EfHkbiiRhpzpxHDyiGHAbEt0/D
	0thZ/WkfSdZBDvSdOL1U/FfioMBNy3HQCBB4TxVWgwR6ai3L/prVdxH0vFPtIpvS3Rlfs0OK6Mm
	QQb8az5l1H2ADX2cCeLx3RULIKrxDLinnMBztlZrkRn0hSlyHLrGZaM7t5GI+m4LmD6K1gfQOCH
	ozwzFJJ9Gegy/eLuX1HUkR9kR72acJPvXjG01lmBYAhRWe6xeiv8IJewP8fyLvbyBiPIQWhq/xk
	l8ZJ9DSiOMhaomvfKugjypcC+YBl74w8+kFFt1iuqD+f5TaG/zxjeAEePca0m3thBdvJa3SzRVm
	bIsR88xd2B6xGArpSHh6lgv0W8zNpkppzxQ+sypwn/nTQU2b91x9iP9qUnHjFLysCnVUeIpfAqL
	kSOmAQyugrqtpyOImH+3FicSqXC9n3U+yQlaSEassf5yn5YFtdb3iRy4gFvD4YhnhfHuvIRw==
X-Received: by 2002:a17:902:f645:b0:2c9:fc14:588f with SMTP id d9443c01a7336-2ce9ec0f95fmr137040705ad.29.1784047193513;
        Tue, 14 Jul 2026 09:39:53 -0700 (PDT)
Received: from [192.168.0.160] (c-98-225-44-182.hsd1.wa.comcast.net. [98.225.44.182])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2ccc9d1e914sm118986685ad.50.2026.07.14.09.39.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 14 Jul 2026 09:39:52 -0700 (PDT)
Subject: [RFC PATCH] freezer: Restrict unsafe freezable tasks to system sleep
From: Stanislav Kinsburskii <skinsburskii@gmail.com>
To: rafael@kernel.org, pavel@kernel.org, lenb@kernel.org, mingo@redhat.com,
 peterz@infradead.org, juri.lelli@redhat.com, vincent.guittot@linaro.org,
 dietmar.eggemann@arm.com, rostedt@goodmis.org, bsegall@google.com,
 mgorman@suse.de, vschneid@redhat.com, kprateek.nayak@amd.com,
 skinsburskii@gmail.com
Cc: linux-pm@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
 linux-kernel@vger.kernel.org
Date: Tue, 14 Jul 2026 09:39:51 -0700
Message-ID: <178404715617.1031850.16243528040694432110.stgit@skinsburskii>
User-Agent: StGit/0.19
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit

TASK_FREEZABLE_UNSAFE is used by network filesystems for sleeps that may
happen while a task holds locks or transport resources needed by other
tasks. Allowing the freezer to park such tasks for administrative freezer
requests can therefore block unrelated users of the same mount until the
task is thawed.

The original purpose of these unsafe freezable sleeps is to keep system
sleep from being blocked indefinitely by RPC or filesystem waits. Preserve
that behavior for suspend and hibernation, but do not freeze
TASK_FREEZABLE_UNSAFE tasks for non-PM freezer requests.

Make __TASK_FREEZABLE_UNSAFE independent of CONFIG_LOCKDEP so the freezer
can test the unsafe state in all builds. The lockdep check still uses the
same bit to suppress the locks-held warning for these known unsafe waits.

Document the PM-only freezer semantics for TASK_FREEZABLE_UNSAFE.

Signed-off-by: Stanislav Kinsburskii <skinsburskii@gmail.com>
---
 Documentation/power/freezing-of-tasks.rst |    3 +++
 include/linux/sched.h                     |    2 +-
 kernel/freezer.c                          |   10 ++++++++++
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/Documentation/power/freezing-of-tasks.rst b/Documentation/power/freezing-of-tasks.rst
index df9755bfbd94..0ccf2ea041cf 100644
--- a/Documentation/power/freezing-of-tasks.rst
+++ b/Documentation/power/freezing-of-tasks.rst
@@ -16,6 +16,9 @@ II. How does it work?
 
 There is one per-task flag (PF_NOFREEZE) and three per-task states
 (TASK_FROZEN, TASK_FREEZABLE and __TASK_FREEZABLE_UNSAFE) used for that.
+Tasks sleeping in TASK_FREEZABLE_UNSAFE may hold locks or other resources
+that make them unsafe to freeze for administrative freezer requests, so the
+freezer only freezes them during system-wide suspend or hibernation.
 The tasks that have PF_NOFREEZE unset (all user space tasks and some kernel
 threads) are regarded as 'freezable' and treated in a special way before the
 system enters a sleep state as well as before a hibernation image is created
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 908aff695ef8..67e052dee1c4 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -122,7 +122,7 @@ struct user_event_mm;
 #define TASK_NEW			0x00000800
 #define TASK_RTLOCK_WAIT		0x00001000
 #define TASK_FREEZABLE			0x00002000
-#define __TASK_FREEZABLE_UNSAFE	       (0x00004000 * IS_ENABLED(CONFIG_LOCKDEP))
+#define __TASK_FREEZABLE_UNSAFE		0x00004000
 #define TASK_FROZEN			0x00008000
 #define TASK_STATE_MAX			0x00010000
 
diff --git a/kernel/freezer.c b/kernel/freezer.c
index a76bf957fb32..bf7bb15c144f 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -124,6 +124,16 @@ static int __set_task_frozen(struct task_struct *p, void *arg)
 	if (!(state & (TASK_FREEZABLE | __TASK_STOPPED | __TASK_TRACED)))
 		return 0;
 
+	/*
+	 * TASK_FREEZABLE_UNSAFE waiters may hold locks or other resources that
+	 * other tasks need in order to make forward progress.  Only freeze
+	 * them for system-wide suspend or hibernation, where failing to freeze
+	 * them can prevent the sleep transition from making progress.
+	 */
+	if ((state & __TASK_FREEZABLE_UNSAFE) &&
+	    !pm_freezing && !pm_nosig_freezing)
+		return 0;
+
 	/*
 	 * Only TASK_NORMAL can be augmented with TASK_FREEZABLE, since they
 	 * can suffer spurious wakeups.


