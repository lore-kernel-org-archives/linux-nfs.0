Received: from mail-vs2-f43.google.com (mail-vs2-f43.google.com [74.125.227.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27AA53AE1BC
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:56:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789477013; cv=none; b=PVvFsPd4v8ufkEnQyDCj/Um4J8EgfHomGcZBzsbYNf0ImNlFy/iURMCeuhKKsLv8uQHTP8nVKwCRs+YaNendjvKMHOWYLXvP7F+SxPyQIHHBoUcCYgEnFjZobb5bXve/E2ZcXDz0yqOxZM7BemhQBjCVTY8dD/ze1WKAVxu7/so=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789477013; c=relaxed/simple;
	bh=3x2XNScpLA7pdu8iUE5GPOaaChTsijxgHbzAPrI9O+0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=r0JlFzZSG6BP0aL04VQ4Jn+iRcJvuGDN3l7K8rsuq/t4o/dP09zounBq/sQ2VqdMvbnHfLI2HNjzRUVw7t01AnNZfYw/10NsvDqn5rSTg6gBlI5WZa72+giw5FhRb93/2UvypbdlD2zGyb205BSeyutQfFfWLT1YyWzBCpjQy6k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=kHK+461N; arc=none smtp.client-ip=74.125.227.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kHK+461N"
Received: by mail-vs2-f43.google.com with SMTP id ada2fe7eead31-785643199c4so979453137.2
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:56:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789477011; x=1790081811; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=bDZF9JSId7CCV6qo5hkoNAYzi1vRwU33Ad5zVuVmN2o=;
        b=kHK+461N4eamGh90QLwK5yBx1QBIaLqgqDpYLw4IofPRhk7aS8e6GMSlw1jmHHZqQe
         fc42e+JrJIi3JkDOvqQetv7rQB0GnwP17tPIZka5PpX8gGkmeXxpgj9egY8FQfjIyaSc
         OvQsIFHZ14ZdxjhaePA5VsIbyswtUycFjL2eRuL9aigSTX5tGURxT4Mo3vRiHVRAzZy4
         U7x7GRj3+97hF76YF3xL+fEMcmkP+etDw/kj2CdTPkmn/tckGO5UU72rpI3IPiRt29R9
         FDI2MDVnigBy/mWLOcpBd408ZroW6Styr9iIxmd5DM19WhCg5P1y91Sx8OFAd1GjtaQ4
         jx6g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789477011; x=1790081811;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=bDZF9JSId7CCV6qo5hkoNAYzi1vRwU33Ad5zVuVmN2o=;
        b=NUDP9rXNpvMUQPTO/xdShAHrTG0Bb3EdPfQPbcQDFG5dmEpN4hVnUFQPsYeJ74UXdu
         /3XSje5+a6wGj/5xr3Hbhbu3b3lRUfCJT2UCrDUMU1saZqVLGdGH/fZSU3pLg6EUzw3a
         JSzXmFU7lQRJF+ttJwoMUQdQgDrge7PSjA2okUTlU7skMLlKob5J1E4MpGRE8CMZBNa8
         lgldvJntAP04X/x7CVLYdVH+16d64h5RJugE1PrGLTCndaSM/Or2ft0A+XBwhSYxZ+Jm
         PWyiLqGkG0Un7R8GaMDfkI34lRhjXltARMaS//nU6pN+g9byUNw4gfNaqtKkybPi7GUZ
         yQNg==
X-Gm-Message-State: AFuF++mEOaiQQ4P5UkfQW7KH7ZJ7egVqNdUG3Z4JjilBviLfUJrEgQZv
	IuXAQdzI/vjBR2ozskRF7yPK4PfWtqgvKCTVoAwB3/qibjpLEbvircSx
X-Gm-Gg: AYBFou1LBep4Bcuqf1O75/alDUAnkvFGp6m2Azjtg5Bmpf+flAzM03LBmFuGx2ygbdW
	GzRzIoMybX69kAyzDTpz6Gkj3+o1w9vVRRzsjul6mfQ8DY5dA5IBJCqX/rqLwfHtLUR07pGiCqU
	RxpOn67VfUYU9zIxuEgYm8hTcFQ0Qq1MjrDEFdHM7V+ZQDkOQ+Hvy0kIkg9+3MRSuxnRXPmXbgz
	p3G9oSUP7kmvlONypWJysqojvNE6gSSeCAZXCw3pg59obA1VDZofnVwncaBgJuQL3xvtZvAaJSY
	qGnq4UWZIbPC+ydSRARriBl6RrDmjWHGkpt/WjwcEcjt0LItk9YKUc0un4DUhU9rVsEwbJwT/8e
	D9mHDTo/nwy/ssJM4uLheJcs5NGUBtsweEJLj3d64SqX0MHO46d0SrNk5KDhEd0nUBeaSu+sNT/
	T6kIhVIhmSSoz5xyS4PaxlvM0wh5+Zxoh9DZsDJNo4ig/ZJT4CWHfqqTSYNfESvFVm
X-Received: by 2002:a05:6102:3f0d:b0:79d:5bad:4c7a with SMTP id ada2fe7eead31-79d5bad6c78mr2752414137.9.1789477010891;
        Tue, 15 Sep 2026 05:56:50 -0700 (PDT)
Received: from beelink.. ([187.13.206.89])
        by smtp.gmail.com with ESMTPSA id ada2fe7eead31-7927eb824absm13220097137.8.2026.09.15.05.56.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:56:50 -0700 (PDT)
From: Aldo Ariel Panzardo <qwe.aldo@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	Aldo Ariel Panzardo <qwe.aldo@gmail.com>
Subject: [PATCH] nfsd: propagate SETXATTR value decode errors
Date: Tue, 15 Sep 2026 09:56:36 -0300
Message-ID: <20260915125636.2849626-1-qwe.aldo@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_decode_setxattr() stores the status returned while assembling a
non-empty attribute value, but then unconditionally returns nfs_ok. An
allocation failure can therefore leave a NULL value buffer paired with a
non-zero length and allow compound processing to continue.

Return the decoder status so that the operation stops on the original
error.

Fixes: 403366a7e8e2 ("NFSD: Replace READ* macros in nfsd4_decode_setxattr()")
Cc: stable@vger.kernel.org
Signed-off-by: Aldo Ariel Panzardo <qwe.aldo@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e17488a911..27c1b42384 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2435,7 +2435,7 @@ nfsd4_decode_setxattr(struct nfsd4_compoundargs *argp,
 						&setxattr->setxa_buf, size);
 	}
 
-	return nfs_ok;
+	return status;
 }
 
 static __be32
-- 
2.43.0

