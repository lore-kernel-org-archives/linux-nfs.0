Received: from mail-wm1-f47.google.com (mail-wm1-f47.google.com [209.85.128.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A551355F49
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 15:38:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787931537; cv=none; b=Ij/rzvERQl8HPIifec32xDCgjmhx4oA7XZJ4OWdFjB8cuMRryEeAGFsUnx5mLS+j3N1g1ehwR5c4ZyEjESfZOUTjm7tJ1uTzvjku5uTwJXEfN91B9LlCYMZVCyBdwgrRbnnTzvxabq4hxVukZ8GpKFtoNf02uvmke28oevHGEko=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787931537; c=relaxed/simple;
	bh=lx+O/DtlW9ws0RmMo8YlCrxxjYpyIl/jTEFGCu3mYOY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=jQhP0NU5laZeLaXSjQ4JoTuhV+L/kiP4c3IuLhnaH1xAe22H9BsjzAqzDjAbBuhZD7bqFGv8L7m/4hUqWcYFyH4HqjSIcj1+Tx+o9rKP7OQFtk33m2QB4kmkinpyCylxkcVj0jslFb3uqqij+SzFABBJGscvADzJr0u3pnth5GI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Tmk4FT9M; arc=none smtp.client-ip=209.85.128.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Tmk4FT9M"
Received: by mail-wm1-f47.google.com with SMTP id 5b1f17b1804b1-493b966dd74so6438185e9.3
        for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 08:38:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787931534; x=1788536334; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=gWsRKGGxkI1G6UusrgOZ42usMgGtUtterCll/lyTGxk=;
        b=Tmk4FT9MRdypXjQpol0csjmeHZj45l85eUyMwKukaxptZDxkc3zgU8WmrV/drNOg5n
         vdWzZVI8EhngWlqr3y5vJ/uxViL7+yUlZw7ckgrA7DOS3mSdvtsHAFc+30n7yseFUR+3
         uhB6tOAjuguCtMHiOOPiDF7YoRh99x7UP/m+A0irh9+Eqy/ZbEdK++jddpNylVHltUA0
         ASc8xIZrw7t1HSSwREpwtvB1Nyv1+RbJjzGI0qkMScU1T61KKyKOHiv9BFsy29b/FYCG
         Ru8dJZNKyL5FIUcUJp2ZuBpoLabMSRDgulSIRrVIvJReaEsfjrpxbOVB0O2r/YGUkWMg
         DuBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787931534; x=1788536334;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gWsRKGGxkI1G6UusrgOZ42usMgGtUtterCll/lyTGxk=;
        b=a1FtYSviwDIxne6RiKzvMvJuQ+J4ZDsvv06nrwBQmgKsc+pdaTJdoRYf3hlzt1bxfF
         gOs/m9BsVLpNRa6ksed9c+z6Xu0Z5Pgh5AsvVhM0Qsk0Ry0l9vB3zIIAdFVzzyUTC70W
         R42PC76ag2o+B6f4gHSMmhtXhadf+YiP6t21LDg07YaJPK56yDctBLoCIZkK5dAwuOoa
         GDscMFMJ6NSt1i2i3S3hDSkRAvoiOtoOWlR3YVXAs9C7RXwzgaVMmzJCfxdqCXIEyuor
         +sbDz3Vtn1nRuN2gnqvOLYqzkWKWZo9FBK6Ae+ZsDpdGrTk+CiGJZf66IcGbvIC6Gtmx
         Hm4g==
X-Gm-Message-State: AFuF++no6ek7TL4WQzbDDdnSL7EJ1CTOuX+kmFUmhAsMcHfEpO2cOO38
	i5WaVrYGvoG9w0/pHdR6COpKuv6blgzhql02DWXw2YYezh0J/j0ctzTcvkSHVYfT
X-Gm-Gg: AR+sD10HZNNUsctKqRQ6dBkDYugX4L1ZmZZ3seMRkWlNkeLB9lBDyzlY0iZyWZWTYww
	11C+b4Ut3jcObm0nHxUi/WRnzdc2IRowxtI7wa7GxSAbzcHuMoBQkmF5z79k2mxhTY50MF1FSWW
	pGpZ31/bH8Qh6DF4RNWYy1XwdEKe8BHXyeHtDIqJf66jYC2RrHNTcxGwu8xIo3G6MXeBYEGC5zn
	grxt4R1qOUBTZa6+z6XiMqjRSagTqUVH3f2sSVaLUjovcUPHvM6Z6sbuiWiPg4972wggjWd5Iar
	izzphZiB7nvCKt50r9jza1wiODDbUQ332cms3ti8aVt39Bp/24OhdiCtlpTT/aUTIF95urcx2bt
	4mpx2hj5YT74S/wCTyc3J/LHt6F30WNaullD9BIfJw8JvN79VMXdoKZ3xrNYSvIwPsNBcD1XYBd
	vnTBLc8wRZn0W1SkEA3wiXl/T3PzLhfTsZN2cZPr3PO/YmpUQLQL51xbgwXlsgrx2H
X-Received: by 2002:a05:600c:a03:b0:499:93b3:91ea with SMTP id 5b1f17b1804b1-49b91c5096dmr102633295e9.15.1787931534115;
        Fri, 28 Aug 2026 08:38:54 -0700 (PDT)
Received: from dyszel.fritz.box ([45.135.60.1])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-49b9266be71sm147277935e9.2.2026.08.28.08.38.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 28 Aug 2026 08:38:53 -0700 (PDT)
From: Krzesimir Nowak <qdlacz@gmail.com>
X-Google-Original-From: Krzesimir Nowak <knowak@microsoft.com>
To: linux-nfs@vger.kernel.org
Cc: qdlacz@gmail.com,
	Krzesimir Nowak <knowak@microsoft.com>,
	Michalis Vasileiadis <vmihalis.tmd@gmail.com>
Subject: [PATCH] rpcinfo: stack buffer overflow in rpcinfo rpcbdump()
Date: Fri, 28 Aug 2026 17:38:16 +0200
Message-ID: <20260828153829.1034658-1-knowak@microsoft.com>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

rpcinfo's rpcbdump() formats a server-controlled list of versions into
a fixed size buffer with sprintf(). A malicious server returning a
large number of versions may overflow it.

Reported-by: Michalis Vasileiadis <vmihalis.tmd@gmail.com>
Signed-off-by: Krzesimir Nowak <knowak@microsoft.com>
---
 src/rpcinfo.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/src/rpcinfo.c b/src/rpcinfo.c
index 30d535e..9917913 100644
--- a/src/rpcinfo.c
+++ b/src/rpcinfo.c
@@ -958,17 +958,19 @@ rpcbdump (
       for (rs = rs_head; rs; rs = rs->next)
 	{
 	  size_t netidmax = sizeof(buf) - 1;
-	  char *p = buf;
+	  int l = 0;
 
 	  printf ("%10ld  ", rs->prog);
 	  for (vl = rs->vlist; vl; vl = vl->next)
 	    {
-	      sprintf (p, "%d", vl->vers);
-	      p = p + strlen (p);
+	      l += printf ("%d", vl->vers);
 	      if (vl->next)
-		sprintf (p++, ",");
+		l += printf (",");
 	    }
-	  printf ("%-10s", buf);
+	  if (l < 10)
+	    printf("%*s", 10 - l, " ");
+	  else
+	    printf(" ");
 	  buf[0] = '\0';
 
           for (nl = rs->nlist; nl; nl = nl->next)
-- 
2.54.0

