Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com [209.85.161.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 914693546DF
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:07:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786644441; cv=none; b=sho0dQ5PddgP7jOcNZstFLqZMnzOmgfkLg37EYSO+lP3VBQ/yho/T01P1wGR7f9R/EZqcMRMvJ4Re4IFb47gHyzZ7/cHuOkTILtzbv2jEFTTkuoveOhVHBNrkJ4fYR+4CwqXlmaadEbkIFJ3VcNAa9HOrw8EyZEfNX/POI32ld4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786644441; c=relaxed/simple;
	bh=1SvZ7ICB1d9VxEx07hZexCWQFj4gTp8rUWAbYOR5peY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=tF73/J0whGJLmGMTz43CzjQbQun7FqhyY9O1N4XDZksbmE4b6g5724nT9anBP8bt5quW5Uu4c5NPBL7DVjHmX0vCMOTXHf4QR0WepEznD7Tb/iJ7fH5kewg1satARK8YZlmt2QQAcMPsBiO60xaugujQ5nTiv9E+UmdjdtJKNFE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=bWCFaNna; arc=none smtp.client-ip=209.85.161.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="bWCFaNna"
Received: by mail-oo1-f54.google.com with SMTP id 006d021491bc7-6acbf97e9a1so136458eaf.1
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 11:07:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786644438; x=1787249238; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=CaTqYX+qot3iPITPtixpdj1Sw6ugoaUAM2Zv53a8v4M=;
        b=bWCFaNna5nfUtkj+Fzc/TEEzZUNKOLPKXOjzjbtaFas3/hh0iIE8iE3WeveWhgkO9d
         70FAP3qTOXKZZ0XJwWh1fyM2D9i59DfzQ6tE8Zl35Y6hzW74RSvCPOm/uPwtGX4kq99Y
         Ph+9JQ7QOHMcPNc8FqtAQ6VldrUIW5cxSdt/H1UwVHn9D6JGmXjerTqUUn/XfaI9upJ9
         HreSEY/TUklqEAYZL+eNTXApiwIDrruqod38AS8DaUWfIO5uGJZ2RDBQpoknWWy1HgTc
         DGh88bcS0SRmNbFQFl06ZpXkqDFwsZQW18SyD1N4Mre/xIhb5yP/YsoBpySXtfEbBJHA
         sDlg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786644438; x=1787249238;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=CaTqYX+qot3iPITPtixpdj1Sw6ugoaUAM2Zv53a8v4M=;
        b=spDzpWUMmEfDexQNp6wEEp9htWmzZApxdBUulQB9LFVByaGKZIWFAb5lGydzO/FOV3
         1yGE5eYYp9nEtwyXeojRemqHr57jCIzZOoiRMKeRN7CyA4thaZ5K2G9GmNpGyLujzJFp
         g+BjeeaAl3xf1Bx2qXSiAQo5fM2LQiRVDb1e5k/v5QUHXLE0LgKFmhNfB8c+IGtzbZ7W
         hsPZb4I0+AKZs+ygYYRxoj1AfjsYcjMg2WhAXxy8HD0unaYI26KOs2idBCcDtP2Z6ZZB
         RzaFY7uzVrNhJyyL5AqRUx54wPeFH7tZwrrnBgB7g6FjZuP5QhziyLwvS+UrCZMrzuv2
         8Lcg==
X-Gm-Message-State: AOJu0YwXDhkS4ruz8jqEAzXMuxL+iJAspf1tLPrMmlaS52kHkWokK15Y
	CAooPF1Z2qlINi8vSio4c61QK9FsFGHGloYNprG6qXCNMv8TwGJ+R680J5wUk13XGWxTcV+RmKZ
	6cKaW
X-Gm-Gg: AR+sD105mOUM3250BbkJYi1aVR3FJV5DO5Qw+B0VM9EuodAG/yCxNFgUtLqToQjKvS7
	vlihAswhQaZbCI0L8zP7Y9jjbXTAB5ezrhXvADjkzyqnpjGaYL8WQsYEgqBAmJGRG4PWTxUYRIF
	VumtP7es2F5vAVUgx8heMT3NfWxVhoaGVk4S/Qv40/62AK4tE3s8kJ6ekmzCIvfBqB49STz04C4
	W5lbfaHJDGYt6pYAkuzxNTUcthHT5SyS2bCRoA47m/Goch8ODdsH3q4acdYdDf8ghBHoukVTBrn
	r4ueQQRPb8k/uFFj+j8vzjZzC6Glw8y2g66/Ip5rw2SisBwFaygrImmxSzHgqhwpqXv+fYotnuU
	yHTWzHJijvhEyruqBoHtSCV0Hc5a8NTxHi0LW06AjvFQh31bq8ClckLlq1vcMFxXgaCwBp1MfrF
	QS3L/aQ2aKe+3Xd6vYfZiSat6WSl8CKzly54dcRBDtYeF3iOam//od+nzoEr6FifbjXqYnXoAF+
	Q4tspmPLYAd/6ZaZkHmjtbwRvmGJmB5iZA=
X-Received: by 2002:a05:6820:2017:b0:6aa:d8d9:a4bb with SMTP id 006d021491bc7-6b0d740d5c6mr211591eaf.36.1786644438277;
        Thu, 13 Aug 2026 11:07:18 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-45e8f96010fsm211730fac.7.2026.08.13.11.07.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 11:07:17 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] pNFS/flexfiles: mirror instance error handling
Date: Thu, 13 Aug 2026 14:07:12 -0400
Message-ID: <cover.1786636529.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a flexfiles data server fails, the client marks the layout for return
and cancels the layout segment's in-flight I/O.  ff_layout_cancel_io()
cancels I/O to every mirror instance rather than just the failed one, and
cancelling a request that has already been transmitted does not stop the
data server from executing it.  Those writes may complete after the client
has sent its LAYOUTRETURN, and the metadata server will see writes to a file
for which no write layout is outstanding.

Patch 1 reports the operation the client was preparing to send when a
data server connection fails, instead of OP_ILLEGAL.

Patches 2 and 3 let a layout driver cancel I/O to a single device, and
pass the failed device down from the flexfiles error paths, so that I/O
to the remaining mirrors drains before the LAYOUTRETURN is sent.

Layout recalls that set clora_changed, bulk returns and revocations are
unchanged: they continue to cancel I/O to every device.

Benjamin Coddington (3):
  NFSv4/flexfiles: report the intended opnum when DS connection setup
    fails
  pNFS: allow layout drivers to cancel I/O to a single device
  NFSv4/flexfiles: only cancel I/O to a failed mirror instance

 fs/nfs/blocklayout/blocklayout.c          |  6 +++--
 fs/nfs/callback_proc.c                    |  2 +-
 fs/nfs/filelayout/filelayout.c            |  4 +--
 fs/nfs/flexfilelayout/flexfilelayout.c    | 29 ++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 17 +++++++-----
 fs/nfs/pnfs.c                             | 32 ++++++++++++++---------
 fs/nfs/pnfs.h                             | 14 ++++++----
 8 files changed, 64 insertions(+), 42 deletions(-)

-- 
2.53.0

