Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297429;
	b=EqJ0Qb/axMZ+OOPKu0QTmVBcQ/8wPAvdJtINA6q9Ew1iPJpWA7KBvZ9/PPG3yh+QjNmc
	 wswe/hPKj81MqubhB1DjPyjszmkGWN1cP7auygx2Cxt00wuMbFHMhAxaXpoImfI/nQXKU
	 wl9pZlmOwmm2cvahapBmVRK3rN5Ps1QJO+BlUcF+Cd/5+LksmxGjG9vOIeIjkmNrAlU1u
	 ivH+oJUQlimDpKXKPeZOsKNC2Ujrzl2V6Vx4GBSDx+bLcBs+3pkoNFX5mnpEIuqGDxBZF
	 QtOw1u1/BZdmo8b75Maz40iPaC92Eg6PjKqLNBzASidVVaFW8CeDPVDUU2A/vpIsBFg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297429;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=h/Q9DLGqoDPx/XvjFFuDFe37sX7w21EVwh1yv9Pf91Y=;
	b=VYpI2anQJDdLQ6Ro97endM4s+M2T9xg/+3HNiRDDAVCKMExLymWKaqjAKNZbacnPlZwG
	 c4TggtIjbgPhHwGHCVUWSRsjucJNd0jWryEjKfNGYm/ehE5ksm3bifm3AXYJzWgJQOAXF
	 LMcsQOyaneOCvQM7jAJGCl1TbFM6l/a9eceIL5j71lzEDjrLjABgJI5Sv460ChC40CQvH
	 1ddpBjs9ul8F3qm/nrBu1quVgCj4x/GwGUEk7fBKdLHZ7DK0G78QVHMrv58D30VFkip8C
	 pQV5zjrMPn4KG82BB6kn7pYe9EG1xQMxQYlVAmbKFQzo9rgd5mTsg2ecdSPi32zjtQA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=K9KYxWzC;
	arc=none smtp.remote-ip=209.85.210.44
Received: from mail-ot1-f44.google.com (mail-ot1-f44.google.com [209.85.210.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E66CD60A3836
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:10:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E66CD60A3836
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=K9KYxWzC
Received: by mail-ot1-f44.google.com with SMTP id 46e09a7af769-84a248254f4so1505271a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:10:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297428; x=1793902228; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=h/Q9DLGqoDPx/XvjFFuDFe37sX7w21EVwh1yv9Pf91Y=;
        b=K9KYxWzCPyBeEIuu0xpic15O7tkqjAgj1nlmkbsQeMWvTEey5aLgbok8m4unZflqLY
         rs5fGM87nV69qB8wilEMbeXeAE88KP9x+lNfrUrKwQArfvUXNC2uV/OQZrUUapzQoqms
         vl6mrG6fe9r5iM3347P0w9f4+fd3IuhyxmhGFebTjl8VZR43FAFyIgmRZSZ33LjLmsS4
         OP3WuXl2s/15UqqSNeOKc0PXcccomgQi8PL12E1a2styv3LRLiireJIzjhCmd38KLQC1
         0y1fJALNITtpO1nxWvBnGQDumgMFnQjGS7ppjXFe2g4UxkNjTRViIV9I8CyqKY0Y5IdR
         ZV5Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297428; x=1793902228;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=h/Q9DLGqoDPx/XvjFFuDFe37sX7w21EVwh1yv9Pf91Y=;
        b=OtltDToahd7vnwmSxZPo2ljQWXDmHqWaN0HkatA5z5njzQq+swTLH3F2uSuG3iLxOE
         81YCVBCfcZGIgNXjrxy6m//DyBBc3vEhwEmrMzdyfAom6D3saM+RdBQKialMtinZVagZ
         N5CtKleh/7LyFtM1ZpZ99bM7dNrU/E57zKeq/SYNtCAodl7TjWLbpUumEDGe+13XjnNu
         wjizYwa0Fd4zPVVnnJQNQgBztVwbs0Vhgc6+GKNFJ56dZ7cZJ9SImUHeQCRdabHfrZ+g
         qEgZG/k5tWpOFcbPCI0pW+XnhLzEof7vHqaRNs1SnR55ngqrn1Qw97wgd0tu5b7suAe3
         cPPA==
X-Forwarded-Encrypted: i=1; AKwUvBwbDS2zmN6aq2MMf7NbOkuNDjIQWffkZZvJ1u+MPNFZctqquiSV8srXjhhk1ZVFfxJ7XJgy/t+H2lI=@vger.kernel.org
X-Gm-Message-State: AFq9FYIN4cC+Tu7ZXP/qoDQyDc15+jsba/eD0pzdyL3QIVRfkc4Nd2ac
	1iYS/06lppDO9ZyyRdcWn9MTY/jB7/RHqUUan7Z7471CUugvp+9EsossPnvvki8RW/o=
X-Gm-Gg: AYBFou1byciCScxn3xpFLc5QGNwVhLtrZ6tmB/lai8O50Ps/ddIwHJgFCXiNTxuNJNb
	IqP8jlWIFhiD6jY1NuIQ5JMd4ix6ztoCK4IaBDIfhrmBOWi917tdvhejqTOVA4G4tqS4lsx2eUT
	L2qWl3xpAJKgioN8W8ZbY6Rx39z+Kr4C92Qaacd4+73lHgEJtbEmHIxbqtRQ08nyqFNt27PkQh4
	alupgmIUGHAb8vJf+RayyGqVLC/3sSjVQRUjDtmSKkvtfyJZvWhLdpu4fIBbT7G9R5fR4PyaLaw
	TkwtNPczUBR83TtPWIULKUPXxF84tAP5UyjCRbQNV+Dj+96wyoLrAdL/PriPO/njkrrLQhjwxtf
	VAdNp9D26bUUcnPG4+Y3q+dfPAK5gE1Inx0b/olDwi6lum0GuXPPAeIDZK4jpFyDBRPDyoIGgUf
	GIYXHloEBnX51Zt0goX1pnIcnz3Lg2eE6BCSIQUqzZfz+IVDOHl6y6TNiz319gAygGxoXlLL6Fp
	28CzFp9OdblbxuABe5dE5GodnyZSnMqy30Jsdlk6bWGbaTg8QNp5jCykCwXvmN+NSV4t61raZjn
	gKDn5XvAoENSKEzPnAa5U7ZV4wEYu2zz/X+gq8MAiNFGMtfhsKAXYQjoZgKQSGHs7UdX0dvS1A=
	=
X-Received: by 2002:a05:6808:181f:b0:54c:7bef:90d6 with SMTP id 5614622812f47-5640dbd679bmr1506b6e.4.1793297427868;
        Thu, 29 Oct 2026 11:10:27 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-563c5437cfcsm4755474b6e.4.2026.10.29.11.10.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:10:26 -0700 (PDT)
From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
To: NeilBrown <neil@brown.name>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-doc@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH RFC 12/12] nfs: remove files with the parent directory locked shared on NFSv4
Date: Thu, 29 Oct 2026 12:09:57 -0600
Message-ID: <20261029180957.387138-13-jonathan.flynn@hammerspace.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
References: <20261028041023.3738553-1-neilb@ownmail.net>
 <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
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

Let removals of different files in one NFSv4 directory proceed at the
same time, instead of queuing one behind another on the directory's
lock.  The server orders removals of different names.  The client
orders a removal against lookups and opens of the same name through its
cached entry for that name, and against listings through that entry and
a count of such removals kept per directory, as set out in the changes
before this one.  A removal it cannot order that way is done with the
directory locked exclusive, as before.  On a server that reports itself
case-insensitive or not case-preserving, every removal is done that way
from the start.  A server that treats names differing in other ways as
one, as Unicode normalization does, is not detected, and there a
removal is not ordered against a lookup or open of another spelling.

This covers every NFSv4 minor version, NFSv4.0 included: nothing here
depends on sessions.  NFSv2 and NFSv3 are unchanged.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fbf9e97815..0acc03dfe6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10860,6 +10860,8 @@ static const struct inode_operations nfs4_dir_inode_operations = {
 	.atomic_open	= nfs_atomic_open,
 	.link		= nfs_link,
 	.unlink		= nfs_unlink,
+	.unlink_shared	= nfs_unlink_shared,
+	.unlink_shared_done = nfs_unlink_shared_done,
 	.symlink	= nfs_symlink,
 	.mkdir		= nfs_mkdir,
 	.rmdir		= nfs_rmdir,
-- 
2.43.0

