Received: from mail-pj1-f69.google.com (mail-pj1-f69.google.com [209.85.216.69])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4696C4156D0
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 07:28:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.69
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786692539; cv=none; b=nBijEZKLPJ8naZrHLycFQiWJ1C6Re9cBvGY/Xfa6NScKzJBatlUNhQbo7U3DNQP9hXc6Jy4DdS4BfRQHjGR4NuhFVkl/t0ZKfupH/EKiXiUSW+T6SMLys9rUnBhLNDvAVV7oD+jXgzqHxzgQZb9M140AHJIbFzJO72ttYNd6EGE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786692539; c=relaxed/simple;
	bh=F+1IYpyjzpe9iHTEepszy6yA5dLdKR2QVmSm5rQcmNk=;
	h=Date:Mime-Version:Message-ID:Subject:From:To:Cc:Content-Type; b=ttMOHlARUModBAywhBJhS56Uix1Q8emIkFrYW7J1Y18XMTZx59097iIHnAMgosMTcV8RTR1gDZ0YYx9ljjDFzD021T21acmWNa0OkHW5dnXS6j3pEcBd6qGLutl2x3dzNR07zMngPUpEvGDE5U0ddTEb+kWeumJQAhHVQN5y/f8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--mariianikitash.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=JBwPI6qB; arc=none smtp.client-ip=209.85.216.69
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--mariianikitash.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JBwPI6qB"
Received: by mail-pj1-f69.google.com with SMTP id 98e67ed59e1d1-38ec0f510a9so1559680a91.2
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 00:28:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1786692529; x=1787297329; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=M14hGkxKzgTjrw+Sf+MeT5uqCNc52Rdu5nt3iXHsVtU=;
        b=JBwPI6qB9//IEeWon2XqnkIg+wmd32sn+e6dktQIrJX/pP4p0ltEZz4kvZgEEDTx5q
         jKBtj+g0Y76q6NyaC2mArIFPB9onbCddk/2LoqTl/XIXA/8NeHKG6FJ8KDbj3h4uHQc8
         Rstt5UJNCwu7MRN42vnp8RK5ecVallPzeoZ6GzcByoymAQ8TQ/NpAFwHi6LXNtYMtfot
         YY/kNp0CgphdUeRi5IQegznxCH81jwVZ+sO+0AslGQa+SshJ3FhYXmX6jeM3VJ0U7In6
         0LXzrmhDBN53fJA4RzAPvLlZ3Q9SACsr/3u6U5kQ1i8JFEbWq9r9nI+1nVNc8M3m/n2Q
         H2Gg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786692529; x=1787297329;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=M14hGkxKzgTjrw+Sf+MeT5uqCNc52Rdu5nt3iXHsVtU=;
        b=pQk+YQcGZVMy10cbVd9scrdp7ddZZ+/nrSGO8ZsEyCeX4N7UdVdTXWoZt11KkZrdzy
         HbTzyOdpNRhy3MVxippiQqnbhwg2oLbDGyxIlxKalGaQKA8xAUKTWith10FyqfQ7GvWk
         25aLCKjGlEVJ8NC6jFKj+0YeNVzwYZMb/TdfugVYkAb82wmJGrgiv0PysJKGaofdVPHk
         aRCAQeV8MQBEN67X5KaQAnOPdQDwRuNaOYaNwiAvcD7MxmKrOBAGuQK3VpGxbX2hZ0ZY
         XkJn17JUY6bjRJfu0a+uzm4lsaJhd1kRToDlPFVAFjs4PfswvgM19w40Z3HUck+cPddl
         jRQw==
X-Forwarded-Encrypted: i=1; AHgh+Rq8eKhpXWIhOq1mGNPYHOEqSFT7dTChYIL9N9UcBuwEbqvWX2FZ3NsxFxlOKt7Nn7lBp0PklOLOvdk=@vger.kernel.org
X-Gm-Message-State: AOJu0YyBVESrH9GYgWVcjA+X0mZvqKxiOdD6h2bYrQ1ZQzAddKaaFhyO
	BNM8HIYqtkgyELUqLt9e6BI8ou4G3rF5MV5MPygdEXFjEcFLgE0PihnbXow1uo14sBNrXvhUc5j
	KxVvk94pJgbkZuFx17UK/VdfpKLB/8VGT923fiA==
X-Received: from dyco25.prod.google.com ([2002:a05:7300:51d9:b0:30e:953c:b434])
 (user=mariianikitash job=prod-delivery.src-stubby-dispatcher) by
 2002:a17:90b:48ce:b0:390:b41a:b92b with SMTP id 98e67ed59e1d1-3933b6d05c3mr4722707a91.4.1786692529154;
 Fri, 14 Aug 2026 00:28:49 -0700 (PDT)
Date: Fri, 14 Aug 2026 00:28:45 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
X-Mailer: git-send-email 2.55.0.691.gc56d675ccc-goog
Message-ID: <27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com>
Subject: [PATCH] NFS: nfsroot: replace strlcat() with snprintf()
From: Mariia Nikitash <mariianikitash@google.com>
To: trondmy@kernel.org, anna@kernel.org
Cc: keescook@google.com, justinstitt@google.com, 
	linux-hardening@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, nikitash.mariiaw@gmail.com, 
	Mariia Nikitash <mariianikitash@google.com>
Content-Type: text/plain; charset="UTF-8"

In preparation for removing the deprecated strlcat() API[1], replace its
uses in root_nfs_cat() with snprintf().

Build the separator and source string in a single call using the
remaining space in the destination buffer. snprintf() returns the length
it would have written excluding the terminating NUL, so comparing the
return value against the remaining buffer space preserves the existing
truncation check.

Link: https://github.com/KSPP/linux/issues/370 [1]
Signed-off-by: Mariia Nikitash <mariianikitash@google.com>
---
 fs/nfs/nfsroot.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 432612d22437..e951fe731679 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -173,12 +173,12 @@ static int __init root_nfs_cat(char *dest, const char *src,
 			       const size_t destlen)
 {
 	size_t len = strlen(dest);
+	size_t remaining = destlen - len;
+	const char *sep = "";
 
 	if (len && dest[len - 1] != ',')
-		if (strlcat(dest, ",", destlen) >= destlen)
-			return -1;
-
-	if (strlcat(dest, src, destlen) >= destlen)
+		sep = ",";
+	if (snprintf(dest + len, remaining, "%s%s", sep, src) >= remaining)
 		return -1;
 	return 0;
 }
-- 
2.55.0.679.g6767b8d81c-goog

