Received: from mail-ej1-f45.google.com (mail-ej1-f45.google.com [209.85.218.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99B8433B6D1
	for <linux-nfs@vger.kernel.org>; Thu, 11 Jun 2026 16:01:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.45
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781193719; cv=pass; b=hPPgrXuJbEGVfwqQWg96+FmDET98vQ0Bv60kvIqN7XA3xGwKI0E6vnaT0l2t/zxh9o1aGPwH58kzr/Pb43UpL4wNfmJBlXA+J3hYpR6KqR2g1Oi6Ym1XjXU600gQz+R7UOxEYsDPHa6eXM+zuaF0dUp7mGLMWMowx43Q08KMT4M=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781193719; c=relaxed/simple;
	bh=MwoxlNsxEc66k8Qw60ikOAaH8UrKznqfoSbN0fMrKA8=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=bZPcxZWuoBAsLLlvzNY9vQpszdtKivRVsAUK/AHIsxQgD1nUlsF+17idq6Fii8c1EGGyFsisegLT2KqxfIznZr8UnU2hjq+dNuajiXyECX7TckwZ6Mem576F2n/TbF5nKBz730fnEFNoMeCMzTPbsDq/PIM2O6l38qoHN0GvGnM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=jiXk8Twz; arc=pass smtp.client-ip=209.85.218.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jiXk8Twz"
Received: by mail-ej1-f45.google.com with SMTP id a640c23a62f3a-bec43ee8ff0so6032666b.1
        for <linux-nfs@vger.kernel.org>; Thu, 11 Jun 2026 09:01:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1781193716; cv=none;
        d=google.com; s=arc-20240605;
        b=lKEyW1ScaBY03pWEffMhRZrh69Lp/U5Kwx1rSUWdglj1lWs5ZZQgEXPWu+EF7oCe2G
         Az7Kgm5Od32kvpgcAOcyO6dVSGzVI7C1NyFJ/8l16RDcJRILUZtJxscszsGvlgphzl1t
         y7VeKqKkLbZNYuLwvjcy/7MlbuWUyY4o/chAvlozzMjKbka5vGI5tMKrKfteEWfgFsqm
         mTowngFoaD7KwHBxDjyyzo4VhhA+jHnmNOh3wwsZ3ZiWc1f0Hc1VohS8JHjC1w29cKmt
         Z8lYksL81p5BtrLzeoDbq0B8MVKQltLwboSyyZfCDHSmR64HhIeBZU/CP5JRxjdtsLHF
         iDhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:dkim-signature;
        bh=MwoxlNsxEc66k8Qw60ikOAaH8UrKznqfoSbN0fMrKA8=;
        fh=A3pMOUK00huGibGCZBFsLekFLVbB5hHGKjUNNKwO+5E=;
        b=XRJsMzvAXfzOzcoKIQScviSCuZtRgl5aVN/3P8IEJjYVFZYM2Qn5npV6h+ItLM/laC
         qNcoNUnhKqLxHMw3yMiN4Anby9bBxo2iz1kU0cxHXszlFPHBhAqPC+k/DNpRNqSDk144
         5svkPIdAgVi5CVEOcdDmtk4HndbaNo/XBUVAimOymr4YOWC/RngIVBi02q5U4unL/rb8
         Zxl8DBADL3h1HSxiktngqBJuqqNnclq6AHU8YkEqOp1AHwKeWjA3VY/xUxdQll5a4b+m
         5n76mJHgctypxMRaqaF/w+gbWXD47kRwNUY1cj5gsPy0pUwAwbaREnRCkNya1jj2f6v1
         RPIg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1781193716; x=1781798516; darn=vger.kernel.org;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=MwoxlNsxEc66k8Qw60ikOAaH8UrKznqfoSbN0fMrKA8=;
        b=jiXk8TwzXQkQ7xjE88PcuHOahc866lrMRAd7DoSApj5Y8uYX/HVhqCuO3HBzii4PYB
         TAHSWj7XphuLfVQSrI6aPaj4Kkbotuo+y5Z7Nf5gi7w+zuKuGeyW0Xb34QRRMpK778GC
         XYGdqdy9Y1A+HkJaOT9FcmvRMcTUype2vruNUuxoxIaIADaQFFvuV2EsPyiVFK0cePo5
         sbjRMEYeeA0+BdGnEA19wxwzyEg9bQdxbM5T/hL3CSYkOdqzlboXi2LsZAN/DSGuhD3Z
         FNejW+/iyifqbfMHyaDp59TAPWj/+XZLkMJn/VADOV+gsCytvT48O18kO8H8phOyfZ+e
         Uw6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1781193716; x=1781798516;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=MwoxlNsxEc66k8Qw60ikOAaH8UrKznqfoSbN0fMrKA8=;
        b=qlNXxEImIaX+qAGhsk0PVDdztb8LetavjsXLhOeCS4JCvOlr4IxwAWpdTPTECcq3XO
         DQxg8AXvi3arh5oXXvEKFvh9Mf9yvDZlticVUKJHz+SaN87Y9Zvqdt+nbQo9c17ZHXw7
         KzaivXfhInZ+EB2PibeKLMQCyhQzNvUK3EedF0HEPHR6iUKkwfOYsu0Y7d/EkGmT8W9P
         FJsPpWud9eLDPdskGiNcCtYeGZOTiCQYHTEO4SD2lnuFWBNd3mxXwiTu60mS4Hi3NrCe
         hZfSMFSwi8a5u5TSsdKKPw8gUEVgeqWdFq5QK1yU/3+hll8TW5Zk36Jk702HQZAtCQsp
         c0KQ==
X-Gm-Message-State: AOJu0YzixJGhUDH675WS7QyP5GLsfy8WpM0T0ctcdkcVxYSZhWmu9pj4
	+oSqPdJUwq+ADl20IibUaWufuQGKIPKFC+oCCdK7SnW7nS7+0S3KVBkDC5HtswWsq93OFjSGGnC
	xh1Cdz+U6mx5wa4Q65g5EbJ1LS0YyK+moXY44
X-Gm-Gg: Acq92OFgMSJC0S1NbwW47qSsB8kQz8WjuSPGwzfHQpP6Dg3L4YNMn7GjXoxmE8zwRKu
	bspPsocPB+cA/0/VqPjv2rVUKNLIenmQ19RnFCGzfFVJO5fMEx8syHGPAj32xP1eMru02px0yAc
	tC3E2CTTtJUWIJyN2ibImAmFa+S19radJaHV03u+EEn6P0e8u3oyZs6RDGvxnbmm6KDKTVL5kNM
	LJVsNXhkJERq2safkNAbzHr8hXA0DWehd9PTu+hDIsgRVhvkES9W9wx3qcVIhYh1JY4RrvvS7Ue
	Ns/iytYew9LEhz4bHQ==
X-Received: by 2002:a17:907:94c7:b0:bd2:15b5:bf60 with SMTP id
 a640c23a62f3a-bfc7ec3c6demr165347166b.3.1781193715702; Thu, 11 Jun 2026
 09:01:55 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Takeshi Nishimura <takeshi.nishimura.linux@gmail.com>
Date: Thu, 11 Jun 2026 18:01:19 +0200
X-Gm-Features: AVVi8CeOCQPjHXnruenkM_yRZ8WA5MomrhSCyeoVOjkKbuW_iqqtQFWfUI1Et34
Message-ID: <CALWcw=HsVbqgnBE+fW=qO9ULPww8_0amGjgw-f11FuoV2=ftOA@mail.gmail.com>
Subject: NFS swap with RDMA?
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear list,

does Linux swap over NFS file work with RDMA transports?
--=20
Internationalization&localization dev / =E5=A4=A7=E9=98=AA=E5=A4=A7=E5=AD=
=A6
Takeshi Nishimura <takeshi.nishimura.linux@gmail.com>
