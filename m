Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC21B390C9A
	for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 14:22:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789309365; cv=none; b=mG6rsmDFlM4yA0ldAZt1xc/esufHDNPG2GykrsObw8BuPBtAC/EYDCBC7HEbZw0EkkEoJ7M6pZl8NYPVKs5dxAt4qBO0ip8Omy73wpsc/CPQVAkcsUnT2mbRlKYdad/wSyAPqKqYvAPTxN8oCkl5XQg4a9ek48uhXKdn9KsfUqM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789309365; c=relaxed/simple;
	bh=hsb4l7CS0z3nyPEOuoFu59i6hQyBOhhAdCPZut5JMkw=;
	h=Message-ID:Date:MIME-Version:From:Subject:To:Cc:Content-Type; b=BhC8v/3AeXbj96Foy/wIcHgVU3rzOgozqpirQDd5eYtYRIxyNCjUF1PoU2d6TV/57rR2s2lnPAVOzm+l9YYZXRyAo0pOgoTflZAn2QCh4prW0dWxSasJ+7TntYgpWpsI+n+QeoR82+2mIWYS0EzM2qnOXo844xv9NiVd1B4WDqQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=fuHr7zHW; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=gQGuEvGw; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="fuHr7zHW";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="gQGuEvGw"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789309362;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=UGfuZPZQp0iLav4I3e2btBFz80YQ1H8mfwGvAt3QDh8=;
	b=fuHr7zHW3xygYTRHV/e0gMS6j4EWTlDvn2dOPEPmRxWLhodvEwaU2ickg4SBqYk9ZGka9u
	10mMptFw0v0iAZF3ehgPALmPuuSjGRd70kIxy6ohsVFVuLI/SU/SlkqVQ0IJPiXF5+SoYF
	swa60jHiEfwtG4fQhrBsRRYO0Jw1UyU=
Received: from mail-qv1-f69.google.com (mail-qv1-f69.google.com
 [209.85.219.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-388-v5TdhnT7NSysd-a8XgQUQA-1; Sun, 13 Sep 2026 10:22:41 -0400
X-MC-Unique: v5TdhnT7NSysd-a8XgQUQA-1
X-Mimecast-MFC-AGG-ID: v5TdhnT7NSysd-a8XgQUQA_1789309361
Received: by mail-qv1-f69.google.com with SMTP id 6a1803df08f44-912195e911aso33456666d6.0
        for <linux-nfs@vger.kernel.org>; Sun, 13 Sep 2026 07:22:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789309361; x=1789914161; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:content-language:cc:to
         :subject:from:user-agent:mime-version:date:message-id:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=UGfuZPZQp0iLav4I3e2btBFz80YQ1H8mfwGvAt3QDh8=;
        b=gQGuEvGw2CdQBINC9VgpZ3uRtuPujZxU2+XEWrzVhTcZMEByyRhEWW3FXxa/lMsvvL
         UMBkrmCqc5PbEB2bEayOxX+jvdHoRGNDZ9iGjOnNRe6CWiKJCR4Cxx2iofJSXYk286Qo
         ffQphTZuk/4SiedJS/tImzIbRmLk0zkcmJ+pAxSsQ+ojwogXxownw/vaYwEZvtT3SI0L
         t4TzGpBlVmeKQbdraYS+FUpJxmrJ35kdSMfRxwuRcY5QPOd8YP3Q2flU8ewUVLn0vIWe
         yE4TmJhBNjAD+JM1eD1+lwU4jQeuY1KTkqBVZPxgBTzD7U35U+m9qyz5Bj7NmLfCzFt2
         FV7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789309361; x=1789914161;
        h=content-transfer-encoding:content-type:content-language:cc:to
         :subject:from:user-agent:mime-version:date:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=UGfuZPZQp0iLav4I3e2btBFz80YQ1H8mfwGvAt3QDh8=;
        b=T+FAKpWhrR4vag8CUAvXozVGMd/mn4HdYDswZ72OFP/i6JI19JW/D2+Z3Ts6h+Tk9J
         tGNwApfxge3LfaWAlQQZ/yCDqBWr/Rcn+JKCl50GtDY32KY4wuS0R8qSuBo4vvKlgHko
         7jzXRC8dY+W0wHNhYsMLeot8R9Hnxo+s2xw5iHyMzK3kU9ecmJ7x0o4RI5dkm7k0zXd2
         bO17MeefSm5IA4NRy0rmtj4rGQH74I8kPE4Z+Fg6pcqKmlDQutcULDBKbG8zYzk/kFt8
         A2srhJJ1o2MHTVjvnGa9GVgwbky9tiJCzNP2jggeax8RqJRyJKtsGMWTizuy+PpYfVAY
         NtsA==
X-Gm-Message-State: AFuF++lPRifj2ZxqMf1WYgtBz2PEGqKTyU9VZt4Mqg9JiYg8veQZaSyK
	YxUrYz+o0Wl8BgCK5LuHv9he/R5Jte1K8GBty+fTdd5V8ggIBK7k7+DmyxMBzvlvwM+flt0lz0+
	pVq97o4C+vbs9TEhZn4i7fo1Y5zICulvy/zoyYfVh0AiJ2b+BrENJMAuecp2o1w==
X-Gm-Gg: AYBFou3OYDQ6zLtLTztyxyAO8L85ymZKzsTgI1486RradoYTj2kLqskdy7zFXIitHvN
	cwCrcNiYmoo4CrJgpVbqlXyC8JA3k4nFAbh/l2OCzdFogeOydoIvPd0f9Y/eI8Nc7xgFgJ3O2Dl
	EnFDL3L17hTqukbRiQeUg2z1VHJNM7wyj2imnu5XyW096CetrqTOv6fMtIIAB5CmQUHc0Bylfx/
	3rXTmgNpJ5X6iAIzrv9Je/8uMgVvXn1XBZkNJxsNtpH6btEErZY4syh6/DgBu8+O2C4vOHshuvy
	Hj/km+AfBAoNasdXP618o6+nysa1+pAQaaZM08l+5yuZI5ZCmxHbkrPvELi6dyCXB7yxXRIA3WE
	=
X-Received: by 2002:a05:6214:4901:b0:8f0:afa3:594e with SMTP id 6a1803df08f44-9121d8d9819mr119521716d6.8.1789309360784;
        Sun, 13 Sep 2026 07:22:40 -0700 (PDT)
X-Received: by 2002:a05:6214:4901:b0:8f0:afa3:594e with SMTP id 6a1803df08f44-9121d8d9819mr119521246d6.8.1789309360318;
        Sun, 13 Sep 2026 07:22:40 -0700 (PDT)
Received: from [172.31.1.12] ([70.105.247.246])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-9120f2020e6sm71488146d6.7.2026.09.13.07.22.39
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 13 Sep 2026 07:22:39 -0700 (PDT)
Message-ID: <f5edca1f-1ae0-4ac0-8202-d97b1033f972@redhat.com>
Date: Sun, 13 Sep 2026 10:22:38 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
From: Steve Dickson <steved@redhat.com>
Subject: ANNOUNCE: libtirpc-1.2.8 released.
To: libtirpc <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

The 1.2.8 version of libtirpc has just been release.

* A number of memory bounders set.
* Memory management reworked.
* API correction.

The tarball:
  https://sourceforge.net/projects/libtirpc/files/libtirpc/1.3.8/libtirpc-1.3.8.tar.bz2

Release notes:
  https://sourceforge.net/projects/libtirpc/files/libtirpc/1.3.8/Release-1-3-8.txt

The git tree is at:
    git://linux-nfs.org/~steved/libtirpc

steved.

