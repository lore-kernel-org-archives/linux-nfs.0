Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794072029;
	b=nRUt+UOAche1IUE+Yx0DlYs3QmXbttcSILSem8OdC/zzaO3c/vfh+2xxsElZh50c8CUE
	 EzMxY/vgAqn8i605KqdzwXVp77vBE+l51s9z04TdL8v190DenmsKqu+OveuqdYJIInqyF
	 khRt1IC4lQpGlDj91w8LxKJqKMx6/e2llHMHhrnLzz/z72oktpaaETVWSFHcTp4wW+tpw
	 5Ukb2DcQMeVphpo+oGzwKPfZtvjSIbFfIDjBgX6k4XZQne+Lam3DSwJukgigfIG42rOUI
	 yOR6OGwyRv5wU/Ir1bvS4MoG9l/R1fQhF7nvjBAbewgmWjNIVmyoz9zL5wV+qyhWsyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794072029;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=jEaRbiqWXQpbhB3Aa4Pl3793O1HLVBqRkk3LDbL5poU=;
	b=Ccy6ydGdYLUIqTwOslfb3K98Hj91U83F3xpG+uAzrdzMdOex9rW7SFSHeA13LFuWW/wG
	 gZidmQ3rgDacGAKvW/GFLthiScVQ9XhXTnaEs/VQv9YNXYH7tecmvLoIsqaUzOPshSGEP
	 4vkteVnfAYFruNFr/caxjJvgzdxvn2d/axue+Pn1meZ6P4HX0mH5/EXYaH3i0gYut5n/0
	 cu1acUwobJdcy7DxSm0qih3CZzB7Hqr5n0/2QuwmH/ebf2+C8hetr/CxEx+lb3QaquPIa
	 EGHY5vZ9aeWyfCgYABGv6XiCTDrGayDOROTLc7gGm1iF5tewaYpp4ztz+ezh9KwSH4A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=JvOWZhoM;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=dhaB1N1q;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17A97606A326
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 17:20:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 17A97606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=JvOWZhoM;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=dhaB1N1q
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794072028;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=jEaRbiqWXQpbhB3Aa4Pl3793O1HLVBqRkk3LDbL5poU=;
	b=JvOWZhoMhqFG/qVRrcRZV9imWbOBEA/kp6i4f0RsvWI9fnIgq0q1BopZDjxbwQ5N7H/Dkg
	R6hAe0Wa8fn/jTja8R7VmlmmLFBL48c3iaDPO00i+FXKNxY5nX81ivZ+7vCx+wgSTPq4Nk
	xoSSReFf/Qd8sN2HnsDgKUgQ3xJanRc=
Received: from mail-qv1-f69.google.com (mail-qv1-f69.google.com
 [209.85.219.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-111-QaR7X0q-MM2n9nUj5k9K5Q-1; Sat, 07 Nov 2026 12:20:26 -0500
X-MC-Unique: QaR7X0q-MM2n9nUj5k9K5Q-1
X-Mimecast-MFC-AGG-ID: QaR7X0q-MM2n9nUj5k9K5Q_1794072026
Received: by mail-qv1-f69.google.com with SMTP id 6a1803df08f44-91ea3a6c1a0so32394736d6.2
        for <linux-nfs@vger.kernel.org>; Sat, 07 Nov 2026 09:20:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1794072026; x=1794676826; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=jEaRbiqWXQpbhB3Aa4Pl3793O1HLVBqRkk3LDbL5poU=;
        b=dhaB1N1qpu+WxuA0zWvlmKzswEShoz4o942wyXYML256+Jf+m/R+sWTcXqcD6YVQUf
         Lr9HJ2c+KWfEvQir3t5ABHoAx20AqBCZw1bb+hVqK9gb7mCBlhVc8PU/5cmIYrLgpdXw
         MTFGoSTwVG6TO7u7Wbs7DRjSh2UHY+yUF/yCeCx39sD79w/BAoa8Ph3P9dAVlrauA9B4
         rc2A1CmepPBGpgcjf18BMlCOvsx16AO3YLRoTtbdlKOh+b9YhvoL+iab1LP1Ed17AcUi
         Mv1+GOKxhSt+1OPpydccuTnyFKQVpe9gaAe1QlMsplRrEcpENEbi0qn1JeONrq5UEm0M
         yNoA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794072026; x=1794676826;
        h=content-transfer-encoding:content-type:in-reply-to:from
         :content-language:references:cc:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jEaRbiqWXQpbhB3Aa4Pl3793O1HLVBqRkk3LDbL5poU=;
        b=yQ6Fpe1tsHYxS3a9NrE95kIvETGu6Wf3sDu4Y7p95TjdbMCVlyBXvOdNAY3etnJy2G
         BOYhle0RTEXIoxmIgu0g2DljPIl4MA0tCavlDeJIi+XXvcFg8sHwKkyDzVMvEKp6JWiB
         HyAlb6c1ZGfZUTSm0bqFpo4ZhDtU1p9zjBDbrxuvbie6yaxFLinKo9b29Lrc1LLNOOc3
         K7+X0YJj2vQv4U4qJVKF1WJYUkQ2RyY3HTAdDg6sTH4MHzWvg4KJ8UNNpPCWvAHRZeG4
         RSEqdEr5v6xOMH+ydpo5Bn6fKSCXENc6iAjlyAz+MzMzuWx/BNGvwXrU15y1rL8ZYIx/
         jCsg==
X-Gm-Message-State: APuU4Z8X1UOUjt6FqzozV33uTgjiaYZpa03QVHv6OUb+N6wlfI5TJ2D9
	IwDrmI5/Xseiceji0Oxpl/xwDelxZfxPlb8PhbyHfCYUaMrSv9aRrYZR+Wi+XSA5WdBd6l13Tyf
	2HPXJp/bbKUcaKGCx9WbtUFsq7mn0tLN/JXunbxwGea5toPmr1yDAhVgi2NqGTA==
X-Gm-Gg: AYBFou2bcVqbWtZK5SnB6N/UoXw/vB9fotWUQrP4P4VaFpbT6bcDg5b5PlWSzIDdLKK
	g5e0SbF0FHprXVDZEuGHHrDyZkWcnT+67V0fhM11y+i4q8F+mAWgopxQRE0vKZ1kKC2fOP/vixR
	8wOhiIuNX4K2sCBnXwfKl0lZbkbG6SIGX824lWVJdQFwr1Amr5qjGyALkLtkK0Tmd/fCOEyT43K
	9IfIfjR0ZXmDliZqkblsziP9PzsZ4qmtXRH5qiYUyw98ZUUYEd7YZhOx57khgDVBTxuhw7TVZGp
	BfxuEQIWVcHwZ+8Sizv/OrufY46dovlWm4BgN36Y9Nb1yPysxKomm/Mxpv6+vN7GVQ0Wjss3c3F
	LUy7RX2H/bTowa4PrguoBDXN/dVSJUIZv+ItjHs1MV5+Q5g==
X-Received: by 2002:a05:622a:1924:b0:534:e675:4714 with SMTP id d75a77b69052e-54e14e662a6mr94338161cf.55.1794072025859;
        Sat, 07 Nov 2026 09:20:25 -0800 (PST)
X-Received: by 2002:a05:622a:1924:b0:534:e675:4714 with SMTP id d75a77b69052e-54e14e662a6mr94337911cf.55.1794072025343;
        Sat, 07 Nov 2026 09:20:25 -0800 (PST)
Received: from [172.31.1.12] ([70.105.246.93])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-54e26f1bd64sm49954921cf.23.2026.11.07.09.20.23
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 07 Nov 2026 09:20:24 -0800 (PST)
Message-ID: <37889bf6-ca30-4fff-a686-c34fd19187e6@redhat.com>
Date: Sat, 7 Nov 2026 12:20:22 -0500
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 0/1] nfs-utils: nfs-fh-verify signed filehandles
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
 Jeff Layton <jlayton@kernel.org>
References: <cover.1779805943.git.bcodding@hammerspace.com>
Content-Language: en-US
From: Steve Dickson <steved@redhat.com>
In-Reply-To: <cover.1779805943.git.bcodding@hammerspace.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 5/26/26 10:40 AM, Benjamin Coddington wrote:
> We've had a lot of folks configure signed filehandles, and then wonder "Is
> this thing actually working?".  Given the various filehandle lengths and
> types, it can be pretty difficult to know if the kernel is actually
> correctly signing its filehandles.  Claude and I wrote this tool that allows
> anyone to verify the correct functioning of filehandle signing given the
> original key and a list of filehandles.
> 
> Beyond that, this tool shows a way to monitor the configured state of signed
> filehandles in a distributed installation.
> 
> Benjamin Coddington (1):
>    nfs-fh-verify: add tool to validate kNFSD filehandle signatures
> 
>   configure.ac                          |   7 +
>   tools/Makefile.am                     |   4 +
>   tools/nfs-fh-verify/Makefile.am       |  10 +
>   tools/nfs-fh-verify/main.c            | 337 ++++++++++++++++++++++++++
>   tools/nfs-fh-verify/nfs-fh-verify.man | 171 +++++++++++++
>   5 files changed, 529 insertions(+)
>   create mode 100644 tools/nfs-fh-verify/Makefile.am
>   create mode 100644 tools/nfs-fh-verify/main.c
>   create mode 100644 tools/nfs-fh-verify/nfs-fh-verify.man
> 
> 
> base-commit: a806c9d65662ecf5d40c00d60a514e13ada8d76e
Committed... (tag: nfs-utils-3-1-2.rc1

steved.

