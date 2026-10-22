Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.49
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792637637;
	b=3KPhM6zWEiDZQWWGR5SYHyFMMQ131+YD+Eq0LVIUKOFt6gKvl2KmHQTWgb1BxboEYDm0
	 /7AJq/0JfcZtiBMQhYj+TZjfsf8pV7wwL6SSJFX1sTf4zdx9ZNgmtn4WcZ9oeew+KRRJV
	 rY1Xg/aiQjZUnjQEcdAZrTgtNSRExrILGVt31i40tQo85Z8fjkvrRk6f1WjFJzzSyvrzF
	 xjI6bkHYB7bHUTjqNf3EHnh3qal9hntiRQbU3795c8S+WNoVg1BpOSaqhb2AGmIYNgpVg
	 IGyoAwuCtSnQsJwcMIrWZNqlMkgcC+8T0sOAFBvpiowPIQgf86TMIveKy32ElgCwntQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792637637;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=NnU6rs3hrQM9btLPDOKgfodkMRYa3+dqaWM6BzIydXs=;
	b=MWd6/RTMm6o/mQdCrWM/VaO8ns7cilOln4Vg8KmNNy1BOGcyqESM/zOf7Y+ftMy4ZRXn
	 vk/mYd2z0KD2FvgbbRIzVOjndX6fS8WAx03BnUKECk05AqWniaSjOCZcCEoyDocWxx9WG
	 PygeNFYWnWdPn9J5pE/p6HHPpma5aUsaivfgEALajdzNKeHMDeJ+fyD0geUdMoo9FyZPw
	 CnqBTTMVk6phTyaFvp75DtdDqpEoUyzbKCSLqJR7W9kR56A+gJGrHurcWOulp0hJrRK+6
	 /U/RJRhmWOGc8kF2AasU8zR29vYlbxUdtn1kR5MhPYqP6OM/uH3O7TpAaJaJ1MKuBXQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.49
Received: from mail-ej1-f49.google.com (mail-ej1-f49.google.com [209.85.218.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79A2E606A322
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 02:53:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 79A2E606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Received: by mail-ej1-f49.google.com with SMTP id a640c23a62f3a-c4395d31228so195846966b.1
        for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 19:53:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792637631; cv=none;
        d=google.com; s=arc-20260327;
        b=gJ5mVLDwk3K8Wbx6LvUhI1ePhMS+crYudy4ihXQswD6JHcUsPRk6wq7eebmkrW7PSZ
         HqIqYttQoG/I1vQR3uDrbhDTI96Yz0lAqGCpSFqSy51HSVIEJg/xRzB3TWrcFGHqUjkK
         WiGKkOPbWBKhf7mKyO7nu8titlsRJ4HZkDC4pJXjpuguX2/ZJHsxZkPuPXmZo/FeVMpu
         64VOAa7jpzBDe5l+gaxruUSyVd5LaF0s3E8llzJgnCFdz/59lHwS5/fpHT+daujBJcoe
         oQXi07sEslvToylteXa9YO7QDHoQoRzC6TS9Jkz43A1QLPbrbosMz2Mba8Jxxy2krl0V
         OGrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=NnU6rs3hrQM9btLPDOKgfodkMRYa3+dqaWM6BzIydXs=;
        fh=tq26Wazb89KZ2pprp/ah6vfZWJIVeEQurn9uojzGsjc=;
        b=mbFncXEczGvhzKD6q6StHby9CUOzDYYfW7ObU5vU8wDRP/BHySfM7uqT+UeEmGEF0p
         Qhe8kijfVivqqT8bCZ4LzwCk6oBQ8WT1iQUk+gL1xCZ4LkLehSGBfTVLPwQLnJgDRwXq
         IAwm3VMWtpa6cwUrLYtDReki41Ym9CN94otY0biNKKw/PNcS4H8nv0Kx8BdRP9NNahfb
         lThgksm8h5Q1u2roHl8Lr2vMrStVFMmhKoc2UwCcpYsidsdKO9A8v3W2zwwwBsBU2llW
         KrF2Wb8wSogHMDFIKMxTUDH++1aIu0VJSmjluJjmgYXu3j4j6kKADPT062A16aMLEHDO
         YVug==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792637631; x=1793242431; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=NnU6rs3hrQM9btLPDOKgfodkMRYa3+dqaWM6BzIydXs=;
        b=DTOI/PekpHCFwbCxS6btLnjWQNCiYVc9jJXCEYwAmPekEK8t/PxBNEKZNgCm5yMo5O
         ZHRqWqq6Sa4prnp5961iu97eKvO2fCe1P/oDhQUuXQyhe3en4gFePLH+ndAycKrOkdLY
         ZBtVPzCtW837QZIUsvIlXqXaajHAOKuqlnaym36x90uyaZGBsQGk0lDoH47TKDdTDSv/
         +bNghojo2jLNQuKI4CGPrg7pLnnWdQfj43K8C91aQyr5qb1zEo8L/J/KSRypGRSRs42E
         gu3hUif099K3NIyvd05k0+GuTWcbFOAPWaSRNh9N1gfC8G9MuampVJBqQHApn7d+PZp0
         CiAA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792637631; x=1793242431;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=NnU6rs3hrQM9btLPDOKgfodkMRYa3+dqaWM6BzIydXs=;
        b=n37psAo6aePrq82sO2fS7YyKkaffXEWCinS05/e5zsYN20hhmToRpfRA5A7Pd4xPne
         96OFye1TTT0ZShHV68NBKibGfiaJ/1QtKA+cGC6JU4IgGAZphHo5riFfhE+HnSrHjL6L
         +YczT/U4+KbIlGq+S1rTOkGpUr7Xn5lLHNBcbLA09lXh3VBxr2BBMGtoHlyxuN/Ig2Dv
         kZboMp86wQcuWfh7UthUaiMHXPjV9qu5FKKp/cVrVo2rFF8LEtxRDlvRwhhd2cqumj83
         hiyccN70SBxVMZNq0mFxbjM2OhH6zxUpx6xkcrxYVqfrtcwyKk7aBKIsjmwXXGy+dcTq
         ofqw==
X-Forwarded-Encrypted: i=1; AKwUvBzXM0gc79RDjq4cwBC4Gya+WnnC/+paNaxgZqt2RDqeAgvncwl6WnAmQcYnNKH+LRNmeZveDGq5MDM=@vger.kernel.org
X-Gm-Message-State: AFq9FYJFiSrPx/3cGyYMhmbtgJhkiMYgyET7bMChFU+85BoTYGjitcwH
	ZLrVuIR7EP8jzvOoYHqH4X6I57XfzhyHGTSWsLH8VotVup5B82HwZ7xgjWd9hPi7hFq33/SV9Tp
	4CdAbRUgjyRTdzVvnScbnD5Rb/OkjuRQ=
X-Gm-Gg: AYBFou2JoFckIWXNoKcucmc9070rzUc4QQTKBAl8D8pKLmp5v6TgNZdoaZlZ1SDukGv
	A14WrXwCEIw2gfB+apvvm7OF6+oOT+iFTWl8SAoYq4zwrXf5GkQsgFdC6WVaf2UtRVNrVFj+MGG
	jD0kngiWYn881eO5nRmz74Lbj/Rq3WjkEb19r9cwGqXrPQq1hMgF6QJYL47RHEyQT3F6U2059QN
	GXagWAvDnT2J456VyUWqizgFGSKqwPCV68dap47YgPRVyBxtGp1ezht8WfnGsRPPiLxYP5uyPFA
	M/ZBjUOaqxDnvz58LsDKeXJHHew/oLxx0MAlW6AIOlmS3OVGH6ndUKux/WPZH4zi8yi383IFS4f
	SzyJxUiYKRSZ1Di8quFhPhUnfq7x3WKa340ibswPCnYzhLMcAwTFKC0vdNg==
X-Received: by 2002:a17:906:ba84:b0:c41:8e21:4d60 with SMTP id
 a640c23a62f3a-c46791326c1mr341731966b.1.1792637630664; Wed, 21 Oct 2026
 19:53:50 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <cover.1792552161.git.jan.koester@tuxist.de> <f444dffc8e6bf98bf44c02456adc2de40e4ecd95.1792552161.git.jan.koester@tuxist.de>
 <fd20b840-350e-469c-9fd2-008fa0ded62a@slotpi15m67>
In-Reply-To: <fd20b840-350e-469c-9fd2-008fa0ded62a@slotpi15m67>
From: Takeshi Nishimura <takeshi.nishimura.linux@gmail.com>
Date: Thu, 22 Oct 2026 04:52:00 +0200
X-Gm-Features: AclHuK8zMCY_XzKvgZWVeEW29rK2WIKSmZA1a7YbTdfyZ3EtSnPZJ1CNUxd7pQ8
Message-ID: <CALWcw=FYKcDNXeArpsabHiQOAL+cWkF=L3stL6MB0OvVaHei1g@mail.gmail.com>
Subject: Re: [RFC PATCH v2 40/41] nfsd, nfs: carry UUID and GUID owners as
 their text form
To: Chuck Lever <cel@kernel.org>
Cc: Jan Koester <jan.koester@tuxist.de>, Christian Brauner <brauner@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, "Serge E. Hallyn" <serge@hallyn.com>, Jan Kara <jack@suse.cz>, 
	"Theodore Y. Ts'o" <tytso@mit.edu>, Paul Moore <paul@paul-moore.com>, Arnd Bergmann <arnd@arndb.de>, 
	linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, 
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-cifs@vger.kernel.org, netdev@vger.kernel.org, audit@vger.kernel.org, 
	keyrings@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 21, 2026 at 7:44=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
> On 10/20/26 11:16 PM, Jan Koester wrote:
> > Encode such an id as its text form -- "xxxxxxxx-xxxx-xxxx-xxxx-
> > xxxxxxxxxxxx" for a UUID, the same in braces for a GUID -- in both
> > directions on the server and the client, and take such a string (it
> > has no '@', so it can't be a user@domain name) as that id again.
>
> A bare UUID in an owner, owner_group, or ACE 'who' string is a new
> owner-string syntax for NFSv4, one that only Linux would recognize.
> Thus it isn't interoperable with other NFSv4 stacks as proposed
> here.
>
> RFC 8881 Section 5.9 says a string without an '@' that is not a
> decimal number means no translation was available and the receiver
> "should not use that string as a basis for translation into its
> own internal format." RFC 8000 Section 6.1 forbids bare numeric
> ids in multi-domain deployments because they collide; the same
> applies to bare UUIDs, and more so to GUIDs.
>
> If you are serious about pursuing this, you'll have to start by
> raising the proposed wire format on nfsv4@ietf.org before the
> Linux kernel's NFS stack commits to it.

I recall rumors of MS wanting to stick Windows SID in text form into
the NFSv4 protocol.

THIS proposal is even worse, in every imaginable way:
Stuff an unreadable 128bit blob everywhere. I am sure people having to
debug that in the kernel will LOVE the idea (compare blob a with blob
b as human,YAY!), and admins facing the 128bit hexdump will send
marriage proposals to the author, for making their lives even more
heartless and miserable.

NAK, -1, for the whole patch series.
--=20
Internationalization&localization dev / =E5=A4=A7=E9=98=AA=E5=A4=A7=E5=AD=
=A6
Takeshi Nishimura <takeshi.nishimura.linux@gmail.com>
