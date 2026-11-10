Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794297647;
	b=1mWd06ZVyXCTHa+h1jJphZusOp8LxejE9ILHD8XSnhd98p6FkZqNEHEx9FwLehy4DAhK
	 cF06plNt4yhVrzg8a/m3b3U4aj0swgYmif5qRa7/LOELzTR4oaIVnoaCJQHwJ14SMnpZV
	 9yi/iXk0HOhZOfh+FhPzhAJlPb0WfN92q9oCVX2dmDAPWeIvrEoWRttHl04tQNlmWNaQ5
	 R6VZYfoafopDsTvNYpwQIjwuEoVsg07xgVz2AleZ+j8qPb0nAYzmiYWP4o04+80rS1kbI
	 702sTk9UkD7xh3q6uAZ2/eUlt2aaVE+aPVOiGnJL9dlhkjL81cYb0LbvlkxJLOfSKKg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794297647;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=80sWobsat/u+kRGlRXvi1m7JgYp74udJYP3vLOxAEw8=;
	b=ZwBJqLlJlmSIaXDlrsR/1D6rLi0FAiWAXYdVMg6y5YdcxuTGhfJ6wYhUkEu1DZQTCguM
	 4/oMed0y/mhyAPnBnfU7/rCQpVIaqxbQT4Hw7BiH0Uzom5IycBZQ40zbOsFYTx+QRrM5T
	 Zp/Rf3XpyXRf4GXW4Azm2LWstDj4XeBSDu/Qpw9XvPHbLW4w84GpG0GAGvOSglUBuHxTG
	 XjVnc8gJz6zu6Cb2BB20boCbQPK1w6d6d9PMRn4lLDDBxuffU0mQYXlnk8gxivNceRWPZ
	 voboxKhnfUtuzRYffXqC5g/dnUcT3NzdR+7WqmheXXiLFJVIPNxmIYFAZl0YDbbGX0w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=xHjdBMpW;
	arc=none smtp.remote-ip=74.125.82.44
Received: from mail-dl1-f44.google.com (mail-dl1-f44.google.com [74.125.82.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EFE88606A725
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 08:00:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EFE88606A725
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=xHjdBMpW
Received: by mail-dl1-f44.google.com with SMTP id a92af1059eb24-15dd124bbe7so2022531c88.1
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 00:00:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794297646; x=1794902446; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=80sWobsat/u+kRGlRXvi1m7JgYp74udJYP3vLOxAEw8=;
        b=xHjdBMpWhSG+Kdu2FDryC2I3YpxM/MYVW27W7uevJDEpit0PBWkyd78AqN9ELhiA4T
         xcvrK35BDSKEBLZP9SpyFOKa8qLI31SP0XRNw/p4XDH9d0+lp2H0Z4KDr7j7ONvA9QR4
         qAzk2bXs04TLpRHq7v/SpWaeg+/AN4KKxNmUbPA+lU01zh+VxlpbTtTbxnNLPLU5LzxP
         KAtUgL8YnkxElSsqwKaBfvKKbgDqEvolc8vIzJYojvPXgEvXamTJwMTQUKLotmK8hgjI
         RKQ8ieVXqaGQlkSYf2jxHR9ldOa5fp2RfKbL+tBgeSfY7NIMDD/ARgytCCgZsFlZ+/5K
         GFAw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794297646; x=1794902446;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=80sWobsat/u+kRGlRXvi1m7JgYp74udJYP3vLOxAEw8=;
        b=c0uyXgn7i0Y1kRnRfqSxneDG9DvoI/ERB7nuuGYejmYn+a6XXoghurOTNoaWPCRNm6
         iLAvZpE1m3n/ESii43wSPXdsHhHy8CxP/d8ZWBo0KqjFyoJo8vqXVhy28KILhav1E8VL
         vQR/SBjYRRDezlYZeSRBn4y8q0U/TRDCD12P7Iua2lh7PvngzqBLzcmuYRKgmFYxIBBE
         Md/f/rHtg3lv4rsUrfFa/Y0IYzf3iEB0bEyMEEXOBNtmfe2yL7Y5i24Jg7iKK5l4f+3a
         2qOWdlS4dCXdcFjrq4f6nPQWEfwFln/wMRAzJroSv1gHV1+UZO0tF0FNVkvRvW8b2eDZ
         sisg==
X-Forwarded-Encrypted: i=1; AL+hErGJhjmOy6E7BKR85mocb2Pe7QqJoDydPxLHO+G3zWg4EGjmVpKqilmXr+BJ6Uw3Eysx3kaVbcqYjp4=@vger.kernel.org
X-Gm-Message-State: APuU4Z/VG7jWuzL/F/Ote/+ZAoL51TNaSNxmjmVPLvRIlk2PlPrBu2WR
	yTptVU+pwvxfZ+lIma/2wXbkeFDy3h+QJHS2DokE2ooY8/QcmsGb4uuR
X-Gm-Gg: AYBFou3oJo3S/Va9aGf70cvXzA+SwYN/sMb65vEpF1meKVSTjjeWMawASmWjvTOHsQR
	2CyeIkN7oRZE6NOWuyxRGA+D27B4WJc3MeswLwdXBJp4wKpkkD378wqU2HafA7+Hm/2tAdfjE4X
	dWNMRlNomjyXiuTBPngh0qpEz1RYcJzcrS/3D/WVB97YCX1ZStqeGyGb+eZO1n4lMmLfSnS5fuW
	0d9aXxSLmMvq5aTgBLfKWOm0orSikdaJ94AX9+XshZyNC5FzVmbFtPYa9OozHlctQWC//SupR7w
	9kJAb3byucs5b0jZU1Qx7cwNlh/O73+dpWg92pAJHutSKR2GAzTPGIhO9fXHzmdDlD/BmhaXxmA
	1QcnntK3ldy0oYlNNWl9ki+DllmXFYu1TRsHR6F2PdMVWwuRY+E6gYYSBQEwl1htaKmrpgSk1rC
	FmVWPgZxYoDkz5zcdxyQXIHpepOfaBBp9g/P5DfpZSox8wvHEK8fwK8+gDeloMv09gQ9cH2mKKF
	/ceMy0RV70GqTEKTvSwtjs3oKE4zmwg9ougCh8ytxb4zPE1zHJA57AHeVe0d/V+qou4xcVfkCLe
	OvmnIEZTBJddYFKqDag3FSdm9vJg2SgJQ3K8RFKZ1vGsE60lvVxnwEkqKOoRFcIvxa84
X-Received: by 2002:a05:7022:b0c4:b0:144:f089:b189 with SMTP id a92af1059eb24-1b3b618588fmr2363514c88.36.1794297645661;
        Tue, 10 Nov 2026 00:00:45 -0800 (PST)
Received: from osman.mioffice.cn ([43.224.245.178])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1b3b5b11346sm6139313c88.7.2026.11.10.00.00.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Nov 2026 00:00:44 -0800 (PST)
From: Zhan Xusheng <zhanxusheng1024@gmail.com>
To: cel@kernel.org,
	jlayton@kernel.org
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	zhanxusheng@xiaomi.com
Subject: [PATCH] nfsd: don't block on a file lease while holding the parent lock
Date: Tue, 10 Nov 2026 16:00:38 +0800
Message-ID: <20261110080038.232210-1-zhanxusheng1024@gmail.com>
X-Mailer: git-send-email 2.43.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Zhan Xusheng <zhanxusheng@xiaomi.com>

Since commit 2a60db3525d4 ("nfsd: (almost) always open file in
nfsd4_create_file()"), an NFSv4 OPEN with create that finds an
existing file opens it with dentry_open() while start_creating()
still holds the parent directory lock. The open flags lack
O_NONBLOCK, so break_lease() in do_dentry_open() blocks. Before that
commit the file was opened later by __nfsd_open(), which breaks
leases with O_NONBLOCK, and the client retried on NFS4ERR_DELAY.

A lease on the file now stalls an nfsd thread for up to
lease-break-time with the directory locked, and other creates,
unlinks and renames in that directory wait for it.

To reproduce, set fs.lease-break-time=15, take F_SETLEASE F_WRLCK on
/srv/g from a local process and keep it, and run "echo x >> /mnt/g"
on an NFSv4.2 mount of /srv from localhost. The nfsd thread blocks
in break_lease() for 15s, and "touch /srv/other" on the server takes
13s.

Pass O_NONBLOCK so that break_lease() returns -EWOULDBLOCK and the
client gets NFS4ERR_DELAY again.

Fixes: 2a60db3525d4 ("nfsd: (almost) always open file in nfsd4_create_file()")
Signed-off-by: Zhan Xusheng <zhanxusheng@xiaomi.com>
---
With this patch the same test hits break_lease_noblock and the touch
takes 20-30ms (QEMU guest, f66469d9905b).

NeilBrown's "nfsd: switch NFS4 OPEN to use vfs_lookup_open()" (v2
12/14) makes the same change; that series is not merged.

 fs/nfsd/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a82af381a8d..e95258b44c72 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -312,7 +312,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		.na_iattr	= iap,
 		.na_seclabel	= &open->op_label,
 	};
-	int oflags = O_CREAT | O_LARGEFILE;
+	int oflags = O_CREAT | O_LARGEFILE | O_NONBLOCK;
 	struct dentry *child = ERR_PTR(-EINVAL);
 	struct path parent = {
 		.mnt = fhp->fh_export->ex_path.mnt,
-- 
2.43.0

