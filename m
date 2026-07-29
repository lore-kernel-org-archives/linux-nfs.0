Received: from mail-qv1-f44.google.com (mail-qv1-f44.google.com [209.85.219.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D8993B0583
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jul 2026 15:14:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.219.44
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785338081; cv=pass; b=Bi6GJr+BTezqu7aYrsEhLYS6OEqDqf68IugXmiM9o4JcwTPW62aKAGeXD637srhJ9ViTe68D+U/2kovCbyUAIzASp64hyB/LvvUetKa8aZasgDU/uXrfg/QHzDJhIr1Sfshgvvd9/dQBXxCOauQpn9fbYFJIpIx+esrx7rJmCXw=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785338081; c=relaxed/simple;
	bh=KniBoIarsC6jUfj7//g6+w0nFYX+NXfQld1kXZSXya0=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=KyvAhGBclulIgACOHLZ8hWd2VAAjXJ0nDNE2tQnnOK9K/4D4/DizQTM8XGx+DL6/j9qeIHAyM/ne3wYGlub6MimJgMmRqi2Xyw05L82/JviM14gOcvxq+8E4u32AH7FyUH/Ks10qVZAxovFpcrCgeUvyLVHAmQdExMaC1HVYmNw=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=fCHBdVF3; arc=pass smtp.client-ip=209.85.219.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fCHBdVF3"
Received: by mail-qv1-f44.google.com with SMTP id 6a1803df08f44-8ff20870ac7so6944906d6.1
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jul 2026 08:14:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1785338079; cv=none;
        d=google.com; s=arc-20260327;
        b=aJ+wno1ccM3qpkbeUVBM9lVi0jHBoOeCw06peze/yV78neZ3AMj5XAYF1BUtNausPM
         RkoiLSEJ9p4WsM5V8SxVf2gzYmC3qIVOmsJXyJoMKeGgp9nT1pyYDngKFvhNcN+k1sOm
         8UZ2qyyptNpTZT1Rp83PaX806ZLkWA6e1XL5FnQlYYAGvbkEU7xw363k6xvEoO+fRFTK
         ahbxFCLsQuKptMk48b7+vIIHiFMmvd5wkv0y1LRpSWdpHSyVhHLgJTbK8dEz0aN/Eqip
         CSzzTG4DOvzrWg493jT0Y1ky688Bb/n03sifbYjPoB4zKW58CYSzS4/AX3Z8bYiNeQOu
         7BMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:reply-to:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4mL+pZBLKUHZONupNXvHwCPfqh0qQgUJdm2KEVSO+i4=;
        fh=y9Z99F6GgkqCLu6eAfB+xjfj8OGDWIPf9zogsRRDU0w=;
        b=bktZeKmT8EEPpP+TC9OkZctlcVeEXFRU048EvZqWeOfdrxIgwEkKbisY8ApIH1F58c
         UcWpkRZ85ecQ5fBSLrEt1I2J8W38F0ChHjY9o4IUM8RtXLXmIL6CLKMYvuHfQhNeMKE5
         0Eh2GrpbohNPyShaPy/a94BpyHDPggkKMwDrTgUCVLG5A+M+PvcAvq8UWEZAFq8FKSzK
         UJxfEHBJhqcSAP+gUd8bjt593VDmUOozjCBff2S7JMlX+fWOhW2jVzw/AGJXePHetHo3
         p4e8eykW3b4A08in1DdfhjyyMa6rrLPgXt9te46ycn9f9yYmN5YdSsgIq8+aCELy7awI
         Wkiw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1785338079; x=1785942879; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:reply-to
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4mL+pZBLKUHZONupNXvHwCPfqh0qQgUJdm2KEVSO+i4=;
        b=fCHBdVF3j7QYulhKrn72kW0EZ0mLeVRO/W6UMENuMK1VxDY8ZM+Hwfl3NpKDQrfjJY
         eUP0/e/kkAOfxXQ1B/0OGP/QEzNbh6w76CDplFTsE61WPMBFmefgx/ZdobFcAkoZxerL
         51MkAfxFKMwIctOVN2RuAy+nQ+7XqRsGDaEfEoOIn/WdnpsTYa0wf6qihoelWsOR8Flk
         X0+akbNZ/3mCfuc6bapmCLwGMxiE00AgsjyP7cnhOsL+edtUtBbP3OlMkK/iFeJw3/jL
         lMH/Dzx4fuwaHpQIY4cuX2nRRKGfyd77L9u47pmcI+u/RxcYSy3EYe+lSghbWVJJbNf8
         A+uw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785338079; x=1785942879;
        h=content-type:cc:to:subject:message-id:date:from:reply-to
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=4mL+pZBLKUHZONupNXvHwCPfqh0qQgUJdm2KEVSO+i4=;
        b=lOfa4Vq/WtvpNCGFWOXGd/Gvp6+qXibU5mG5DRcoW08Up1c1hqvVBRhK1szR8szUQM
         hTWqf6K1DiA0lOc47dlZ60YhVM3dOS68QBAm38DKB4bXmwaHhYHy9HN/GuNAjGZS6GbM
         Uselmpxpssgeha8WSMbrZafa4Ry8BUOGF6BdfLRmf/gu+I3jTMA4LYYt7d15K8b6DYVP
         +1e2KZcAOMgc/hjaMNnRkb3AdmpgCAzeIHEiolm40QLIYt+KaiVqpPn868qbXzIuh1jO
         91Le2hb8gLqIW8RCt1ebQoPS7VcJLy/itOj4SlfheGRI2xWrJuDQXDssSL9Iv+f4BzhY
         1LtQ==
X-Gm-Message-State: AOJu0YzcSit0fPlmnm4AiezmitYGU0lFfVNRbQWY2fnsY2ZLceVzMNkL
	Tdv7k5X3+mqXDV5BWgteq5EPoqyj//RNtMGsiRAoaUvDM8uEU909woHZ8kUypBmAgQjawv71Rq1
	exrXSZ8WrCze27//XkganGVK+cgJR9Q4lH+wRuE/DLQ==
X-Gm-Gg: AR+sD12GQjgDEPJVPEh1peYgYgLQiJjBHwfDERprVI2QLXciubVlHpm6E2zXV7K3Vrt
	wsPalTDaDxpqD45CEc1+42d20o3s7zuN6n/7oiUAroGKqNRUs6DS7t6pSr2WRdkauM9c2S+obyu
	5/QURaMXgIY3avWA22YfwUlMAQtIABzM0o3AMQR9I30kUsZ0a3TdMILSSqnhaiYkSu48+GSbRxC
	oAJe80ukvKxXBlNbsyUkDYd8k2KamgGpvrp2wX3ZWNGC190uwV0nplKYq1TyKMi1ZHnxHRNKrM5
	j9O7dt+kcfXglhOxnAQhmYF+7wc/gmfLgq39cEXmUL02rtsSrVdnDx8FAZPEWLvz1rV3MG9Jgzk
	w
X-Received: by 2002:a05:6214:1c49:b0:8f0:9d9c:52c2 with SMTP id
 6a1803df08f44-90816fda807mr75724596d6.5.1785338078814; Wed, 29 Jul 2026
 08:14:38 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <dc0f6f41-84be-4a70-92db-89890bded3ab@redhat.com>
In-Reply-To: <dc0f6f41-84be-4a70-92db-89890bded3ab@redhat.com>
Reply-To: mjnowen@gmail.com
From: Mike Owen <mjnowen@gmail.com>
Date: Wed, 29 Jul 2026 16:14:26 +0100
X-Gm-Features: AUfX_mxOsf8nR1_TDDFPIP3g1TG9HPoPWC0Uh7jI27irRhLVewASuT0qGGW2e0w
Message-ID: <CADFF-zfEws+xZ_tOqhC8uJZAFZvwMDtZ5yagDP9x7Umq6zabDA@mail.gmail.com>
Subject: Re: ANNOUNCE: nfs-utils-2.9.2 released.
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

I don't see this release tagged via git here:
https://git.linux-nfs.org/?p=steved/nfs-utils.git;a=summary
Forgot to tag?

On Wed, 29 Jul 2026 at 15:48, Steve Dickson <steved@redhat.com> wrote:
>
> Hello,
>
> This is a fairly large release...
>
> A number of memory leaks fixed (from AI)
> A number of netlinks fixes/enhances
> A number of exportfs fixes/enhances
> A new nfs-iostat option
> A number of gcc/warnings fixes
>
> The tarballs can be found in
>    https://www.kernel.org/pub/linux/utils/nfs-utils/2.9.2/
> or
>    http://sourceforge.net/projects/nfs/files/nfs-utils/2.9.2
>
> The change log is in
> https://www.kernel.org/pub/linux/utils/nfs-utils/2.9.2/2.9.2-Changelog
> or
> https://sourceforge.net/projects/nfs/files/nfs-utils/2.9.2/2.9.2-Changelog
>
> The git tree is at:
>     git://linux-nfs.org/~steved/nfs-utils
>
> Please send comments/bugs to linux-nfs@vger.kernel.org
>
> steved.
>
>
