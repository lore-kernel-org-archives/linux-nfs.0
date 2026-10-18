Received: from mail-lj1-f178.google.com (mail-lj1-f178.google.com [209.85.208.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 185DE404BF6
	for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 19:47:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.178
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792352854; cv=pass; b=GH0zgCyoClPC+j43REgATZfS6Fuemyl2lWZxDuFj7BaGbvpcPwgJ7KLB+RmCvfrFqIIGtFRT9nah0qzCXWG5X+cAuyYwivQTdLPDD4NCiD/vtB84JoWbTWFXOgo4IHKvn/inbKZjJ2Yy9YxjdAo/v32kCtgAN/UlvMuMnbz8ZjM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792352854; c=relaxed/simple;
	bh=uSwsGj7z13o5NrJE21iC68UKNr7h5yOq6P5JpP5TNDM=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=G/bcSyPxt62NLdYBfJgzcN7Hs7joe6LqFodeTjNaqnt3EZInXyI1THVLOYPUr7biJJxJfcnjKV0Nj1MblfAU1JzvswmXCPVAon0TX29Bk3+iEV1XvNNPdjTi5L3Pry8zuEtjQimIhB6Qp1WXWQLMO0ejdy64I0y0/NaBhxTiDaE=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net; spf=pass smtp.mailfrom=amacapital.net; dkim=pass (2048-bit key) header.d=amacapital-net.20251104.gappssmtp.com header.i=@amacapital-net.20251104.gappssmtp.com header.b=U61hr0Px; arc=pass smtp.client-ip=209.85.208.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amacapital.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20251104.gappssmtp.com header.i=@amacapital-net.20251104.gappssmtp.com header.b="U61hr0Px"
Received: by mail-lj1-f178.google.com with SMTP id 38308e7fff4ca-3a75f960be4so8137641fa.2
        for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 12:47:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792352851; cv=none;
        d=google.com; s=arc-20260327;
        b=m65o1OHnL/z6nYydkLhaFjZv7eHayLx3B5zBrs41G+cFvpb3fxddhlSGrviebwC1yj
         Vk6SmejK2MjsP0n8dLIMjpae69gWGfwz656qXXlJ+M6ejSyGTd9gTCeb/xEZFASzT4ws
         ydPzyJlOMCdafdFwtKq1SDom8txlosvsvpDtzMSn34d6FjQevLn0cE6UYMUrE5rhS/Y4
         +qopF5xTY9Ghb28OBbyvwZ8E09wZsoRh9zbHqYmw44BYxqJd6wWTOSTZCIfj09nZ0VOP
         6BJhsgFuFWiX7a2jI7uvIJkZLWeBeBZHQHu/CH1vcxvacdI/J+AdciyUwXh64WqgsoVG
         f+2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=C9PTaRCgfnWLejuxwMwgHezQmSpb/Q49pSzLQ94ksTk=;
        fh=SXMKrw8GURvbaF+d7IZtn6hTdAnePtiso8F4P2cgOAU=;
        b=ZtHyeLwYbCWMaCJaMUjlPKQcBSW2y/ubWJTtwTdn3680wXR8SGgc5hrvSPuauzfbf3
         BGDtK1Y27xZ79Of1rxSIlMwitRSubwdBw2MsY0N7FBJHFhSJhmgi3mSDri4ng19Vuzxa
         pyGpdHEIsKOdq9RHiXGjSjQLdrKnwsOZX1AGIHT8w7mL12RD7JOC//f1iXh+ZZ6Ri/ab
         CZNx51/tt+PyrJUcSJa2VDScRdtqDCewJj1/a68wfw2vGBqp1LHfo4+6+yz84VEnkTIN
         s4hP6ysQUE+LqWfPfSc0oDJQaDyKU177Ybl+ZTzgWrfT+mmU054hIviNbLtUpeBuFf1n
         3sFA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20251104.gappssmtp.com; s=20251104; t=1792352851; x=1792957651; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=C9PTaRCgfnWLejuxwMwgHezQmSpb/Q49pSzLQ94ksTk=;
        b=U61hr0PxGjsekFN/Peus8SSvsCkWL+X4cEShlWPsXJwFZsPSOlvUCsybYg9BgwgJRd
         4XnxIJgNM2UxnPRJ7LJ9ePNZaMA3S+v2khZQd28a3QJuiBcuUaNEpSAyegrHLGxeAQOF
         XWhhz9z4gvoj1jD71wUdmMg7TKUgBLlQEbfCfdSDreL0vc42Gwa+0w9MuT0mJeW9FjHk
         InbXbqmJqWqFBCaE7bhMzpyoImihsnstJokhn5vCptf2p7cb0uxL1CtKsrsoOoa51lXm
         tyklrtgAN7N7S853vG7iCSHElYqHLPGyLpCn9vrAZ76I1HHBL84qCv0LlLe1GVF1/qq2
         6Adw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792352851; x=1792957651;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=C9PTaRCgfnWLejuxwMwgHezQmSpb/Q49pSzLQ94ksTk=;
        b=qxbUUk+WVmuUw9KezVaT72GxIs6ZlfyiYy/oHMXEXyB/Ro8iTgsuimGZ0pbWELGP0S
         OvV+IEaxaJyC+5BEksyvDoNpDgNFO0/8hVim2j2UB+ElQsq6cSWk/dLhWM/nWMGSAq2q
         SczuAS8GZAN+RU1T5qBavHX9rBSYP3jhOOoYL830b9LYqsB+PtEK7dx57ZWXmBw8Il/T
         m+3sJh0gBZ16HQQpBmjvsmWQ9DO8qDFzWrR1IncgWq2JoyaukeS9a7DuPB8mQk7Fffh4
         Qw4t/MszTlPOZnUx+FzZlUJjy5nhn0h5yzL0eQybKnWJmw6B0ydiZI3BmJvVdR7W/BUW
         8TFg==
X-Forwarded-Encrypted: i=1; AKwUvBxq/9vaGoAUgpyv/mvWGp1padh/FXu4/cG8e2VN+Ta2gjb4xZyUxM9PkkAcxszOtsJ8o+8EML8RHJs=@vger.kernel.org
X-Gm-Message-State: AFq9FYJivusKSyMvn3C6eZiiKBhp/uNZmzIj7rtw+l31YZEqDgZtO4e2
	NqvYO4tGukaI/DKAfiS/NIOZTaOCBk/cA5gLFr0zevev0g0rcrwOGVwvJczS3oP7URyOtQhOPhw
	nw6r9+4fN4Y0g/v/nrv4isSu9xVu01Y+RzUT4o2Xb
X-Gm-Gg: AYBFou2aaiVMb+FCsz+0KLbXlOpJL+tqrbUwUpFlW5tb82OgWhIwxfUfJOl8TFmZ62+
	elg3hMbb/sMkzFdFq9TFiot9p2+fgAhfHXrhYgBX7udvfeQH25BJhV9n5Dz2VQqUA8Slhh/kTUM
	Mev677tKHydo3GInlEXftcPBMUst2jetMb3+aTadvhYQX4jonjDIe54evUZkMw1NLNZ9FSygEf5
	BGVLtB6NaJckd3jHLjGtk8TuC9hIYP5AMttragpi6+T5rFhu4X/KSykfrqd9lNwtVyW4TRSCrcp
	Hjia89MVGnj18KKD4EwO9vNn2sgs52Wzm8c5qpVFqejAIh2OG/Rc
X-Received: by 2002:a05:651c:3614:b0:3ab:1639:9a79 with SMTP id
 38308e7fff4ca-3ab292b7375mr9897881fa.15.1792352851051; Sun, 18 Oct 2026
 12:47:31 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <cover.1792346472.git.jan.koester@gmx.net> <9c17a1f7f82b953e6f4d9e17f4ca19d5220d7f2b.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <9c17a1f7f82b953e6f4d9e17f4ca19d5220d7f2b.1792346472.git.jan.koester@gmx.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 18 Oct 2026 12:47:19 -0700
X-Gm-Features: AclHuK_TjVvADO7YV_Of3nNvklGJn7yisT4mnRNh7189wUPwvl6Zlkl0ZNpg8pA
Message-ID: <CALCETrUjRpHSTBzO65uU-YaEj4espqnwDSaSLcXu653xJyooHg@mail.gmail.com>
Subject: Re: [RFC PATCH 09/41] uidgid: let kuid_t and kgid_t hold a UUID or a GUID
To: Jan Koester <jan.koester@gmx.net>
Cc: Christian Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Jan Kara <jack@suse.cz>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Paul Moore <paul@paul-moore.com>, Arnd Bergmann <arnd@arndb.de>, linux-fsdevel@vger.kernel.org, 
	linux-api@vger.kernel.org, linux-security-module@vger.kernel.org, 
	linux-arch@vger.kernel.org, linux-ext4@vger.kernel.org, 
	linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, netdev@vger.kernel.org, 
	audit@vger.kernel.org, keyrings@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Oct 18, 2026 at 11:10=E2=80=AFAM Jan Koester <jan.koester@gmx.net> =
wrote:
>
> Make kuid_t and kgid_t (and vfsuid_t and vfsgid_t, which share their
> layout) tagged unions: a classic 32 bit id, an RFC 9562 UUID, or a
> Microsoft GUID. KID_LEGACY is 0, so zeroed memory still holds the root
> ids, and KUIDT_INIT()/KGIDT_INIT() keep building classic ids, so the
> bulk of the kernel needs no change. The member is renamed from val to
> legacy so the compiler finds code that peeks at it directly.
>
> Semantics of the new ids:
>
> - They are not in any uid_map or gid_map: they exist in the initial
>   user namespace only. kuid_has_mapping() is false for them in every
>   other namespace, so no capability in a child namespace gives
>   privilege over them, and from_kuid() and friends give -1 (the
>   overflow id when munged), exactly as for any other id without a
>   mapping. Anything that can only store or report a 32 bit id thereby
>   already treats them safely.

Why?

>
> - Idmapped mounts map classic ids; UUIDs and GUIDs pass through them
>   unchanged, as long as the filesystem itself is in the initial user
>   namespace.

Okay, so they pass through but don't work.  Sounds unfortunate.

> +/* Like kuid_t and kgid_t: a classic id, a UUID or a GUID */
>  typedef struct {
> -       uid_t val;
> +       u32 type;
> +       union {
> +               uid_t legacy;

Linux is Linux.  small numerical uids are not "legacy".

> +               uuid_t uuid;
> +               guid_t guid;

I'm at a complete loss.  Is guid is only unique on Earth but uuid
unique in the entire universe?  Even Microsoft admits that GUID and
UUID are two names for the same thing.

I realize that Microsoft colossally screwed up years ago with their
little endian uuid idea, and I sincerely hope that this is not some
endian thing.
