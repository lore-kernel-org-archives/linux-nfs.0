Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 629AA3955CA
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 17:17:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=170.10.133.124
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791911839; cv=pass; b=jOoZP7rOjWqlPrJp94X2j2cKYwA7NVRh+/H2ufkNJorsju83m6Z1FPSgn4szMADLOeAsxwxFXkjMgnjFo3yRY5X76MxlMfTjn0joy9zwJ+HsH0lvIDg+6OtNqoXLvP+upxy2VwBosisLiz6M+V0uTzUBGv70do9iw/9cjByse14=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791911839; c=relaxed/simple;
	bh=zaEyIzN5ANOYPcjO2seUEb5efvv0EUFch0zADmClwlc=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=ABooYS7zk3h33fOrSaML9CmBj7BpcyP2s9YZXoPgsTQgrzgMEO9tm4f4RSF0lnyyV1kxK0vbPo9VB1bnBQXRyqwWxI78cLk0nAczzCxpz6yQt/8XMVqACxcnlTPiy02hY+SbLsovwn7TRbC86GCg7vFxg/5oXj+6U7/tmlMBXvo=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=JBnzAkcA; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=HfR2Woi7; arc=pass smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JBnzAkcA";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="HfR2Woi7"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791911837;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=zaEyIzN5ANOYPcjO2seUEb5efvv0EUFch0zADmClwlc=;
	b=JBnzAkcAhaL1W5inIr7U3rbrxDMric/0BaFqwmqTe7CeDldIFvwykOKZVEDVqXco7rHif/
	cNYgTZsRrb7XhBLetr00bm18p+dDsiYK/pPjBmU9KQzhxdnLoYEfc2ayqY/sSjGDexYIzT
	jKCSjEi98qNb8FW3C87GY+GURS0JHnE=
Received: from mail-dy1-f199.google.com (mail-dy1-f199.google.com
 [74.125.82.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-664-ZTj8FMlZPtOEoAFmJ1utCg-1; Tue, 13 Oct 2026 17:17:09 +0000
X-MC-Unique: ZTj8FMlZPtOEoAFmJ1utCg-1
X-Mimecast-MFC-AGG-ID: ZTj8FMlZPtOEoAFmJ1utCg_1791911828
Received: by mail-dy1-f199.google.com with SMTP id 5a478bee46e88-30c0d568830so6695027eec.1
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 10:17:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1791911828; cv=none;
        d=google.com; s=arc-20260327;
        b=VJ8KrqR0NPc1b7yMlFm5t8Kh2Sd2A3o2F9o3dcEvW0QinMrxG+jsv5w2uVNgXcNO0v
         sclHwe42HyQd4jMkaqn+SjqAp/uwr69wTjpeboeynjqSpCuXZCWXPDk9cwWaPCF9gMLs
         z9WDmD0m5TTD0/qel2JiJZKK3zo9peZKp8XanjZEHeuZEG2oz1IWXHigDkemgmiLxxeJ
         K65Hl3ZhtClKGkeS5INI643GyqNEvMLFGVmBj2sWpAS62/CL2JQESBHit30fy66UuNUY
         dqkFVX6ZzsM+nt0g38DS5m0cAO5NBrO0FroK8c0TkTWjTElvtvf8VyDnt08reUak1dpM
         +TbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=zaEyIzN5ANOYPcjO2seUEb5efvv0EUFch0zADmClwlc=;
        fh=GrADM55wb+qJQVuh8ATXyCAi5aMtcvuZHP1jW+30wwk=;
        b=QWLn106K2FdqED1DWh7pST1FsmQADjML8/ODoJvrIliJSy2TR7PHL+X9MTn4L9tVmP
         bu0KFGlhUcoPRNA99kX70/Gp3lnvfrtC5Gb2IWz35HS4bMhPFUUcvf4JVMfC7Xeu7fIv
         x/dDIZUB0K3iezE/6N+LT+0PW0f1sZi8V5UgsqwhK97cJq7UNT/z0lTChi6+aO7brPQB
         +RnufL+5eemA7clni55dE5aopbWQwP6vSim0OZ4bZNcPmTn1kQrCrEWNWK93Yq7VqtdG
         scSUSbERuo7EouX3oEQfkZwMdB6ap56XZNTme1DUMscdP5juVua9P+jDKz1+Q4WT4jyY
         zJfQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1791911828; x=1792516628; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=zaEyIzN5ANOYPcjO2seUEb5efvv0EUFch0zADmClwlc=;
        b=HfR2Woi7q4BdtVgnr+VCgdhRNM/Zc+eWcafUubyD0f5JmnOgxPoOMEUUUJVyfrXpsg
         MfLor2Iq3QGesIrO9nqgC7LyJSP5rEyGQYvyJUITNaZdG7279z8b+3QuAORL1pTGgHxQ
         b9tPZNUiHyiubqz1HddP1gwAvgeytRt1kPdpj/mTr0odEsy+OKlfPkSZqd6x/2meI6Lg
         lxjiS1/IuLvnGE0lCf48cOeYG/F/8hJWC5EWzlbH3UleFZOVtxQ3C6avQ6N20/PWw8wo
         QbRBe7ivOrqia0q9MDRXK+iASJufMqbxfmyBySV/Uqn5l5Bc63IJ6ApwrmZge9IwIPMV
         FGYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791911828; x=1792516628;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=zaEyIzN5ANOYPcjO2seUEb5efvv0EUFch0zADmClwlc=;
        b=OkSaHu50flasHMSzwl3d4l2OllI+SYnpC14XwVg0+Keu3DME0BkIxoLfzI+Vu0X4Ze
         x2QFKzy4uyYU9QceWXSwe1nkBoCULAkoDj1dcdfOv1p3Fb7dV1jPWE3HkZ4vWvK5SBHc
         pV5a7in/BzLz5sbZKRzED5USn0j1m89LQaHVelodCPBcT6hIAv3mv7D9mj/+pw5PNYEw
         Imigi5ETXiGIYFPqGSYhOkMyR4BYXPCb5+8rZR6btsi20+3hpvx8XOeMvORchR2z/a/S
         h48dp2Clbla+h2aMjmap60MrwT5QIUD6YF4yGe2LziJiI5ei954TsFnkvWhRDkn8Tv31
         0DKQ==
X-Forwarded-Encrypted: i=1; AKwUvBzl2MEOi8e6Vo4MrSWXBkRd6kHsIongFjntZLR9i3CwQumBgbfJBasTt5ZihyOKBzDdnuI+4N0ghT4=@vger.kernel.org
X-Gm-Message-State: AFq9FYI8V6oNSVAb5qhMAw3xWHZH4xU8878h265QlveY8pS6bqpFRs/y
	OaIG4ipW+bMnZMKncPv2agcYZFU3iBKDuLV4oJCqKrF9oIX0A8RD1mQ1NXNmkKQ4p9mmUsruJWZ
	p1zKxKiwYMlGX5e0OvDVDdxCSAsc/AydizBAp4OLaehY4mqC8OeW2mld0lYEZFiFv0FJESqHL/u
	wmP9NjC3hGG329p3d2lsLQf8GQd4JibCKj2Rup
X-Gm-Gg: AYBFou1NLe7Z8GhTiGd48WltB8j5Vzp6Hjg4P2FWHa8bWhBgxMmKZNc9D5u/nzz/Ozi
	Q7Vd2n2FtOUOsXzj8xb7Ctj/f/ddH8xczX3XIsLg1M1fLJa88KobyiEdgqJRJ9Sto+1Ln2I8mXa
	6SvRyE9nxjUd0d3Opp5vdyxx2hFQDtzoaBxNs7ZhoZNWus/5E8rol9B+5+
X-Received: by 2002:a05:7301:fc8b:b0:34e:67d0:bbb4 with SMTP id 5a478bee46e88-3537e03eedcmr15639575eec.10.1791911828365;
        Tue, 13 Oct 2026 10:17:08 -0700 (PDT)
X-Received: by 2002:a05:7301:fc8b:b0:34e:67d0:bbb4 with SMTP id
 5a478bee46e88-3537e03eedcmr15639533eec.10.1791911827810; Tue, 13 Oct 2026
 10:17:07 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260917104905.669983-1-rbergant@redhat.com> <fdb976f6e9b78e2618de70bcf6595e9f484fc30f.camel@kernel.org>
 <015401dd4d17$f0df5e60$d29e1b20$@mindspring.com>
In-Reply-To: <015401dd4d17$f0df5e60$d29e1b20$@mindspring.com>
From: Roberto Bergantinos Corpas <rbergant@redhat.com>
Date: Tue, 13 Oct 2026 19:16:55 +0200
X-Gm-Features: AclHuK9H7bLPShrRuXlgUWnTq4coergrQCatTO4uLnLzSUmKpT6k6MjhTsKxyiI
Message-ID: <CACWnjLwvhFa5nRTk0w5h2mFhFOKbtrjhnB_9V8i097XxbXxOwQ@mail.gmail.com>
Subject: Re: [PATCH v2] NFS: return DENIED in decode_lock_denied if we cannot
 decode owner
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: Jeff Layton <jlayton@kernel.org>, trondmy@kernel.org, anna@kernel.org, 
	neil@brown.name, prabhakar.pujeri@dell.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Trond/Anna, do you have any objections for taking this into the next pull ?

thanks!


On Fri, Sep 25, 2026 at 8:02=E2=80=AFPM Frank Filz <ffilzlnx@mindspring.com=
> wrote:
>
> The thing is, it may not be a server bug. The protocol specifies a limit =
of 1024 bytes for the owner opaque. The owner may come from something other=
 than another Linux client.
>
> In fact, as has been pointed out by someone else, Ganesha returns a 21 by=
te "ganesha_unknown_owner" when the lock owner is not another NFS owner. Ob=
viously we could (and probably will) shorten this, but the owner could just=
 as well come from another client, or be some representation of a local own=
er. Nothing in the protocol even gives a hint that the owner should be limi=
ted to something as small as 20 bytes.
>
> Personally I have wondered of the conflicting lock owner is really useful=
 to anyone anyway. Obviously the Linux client does nothing with it (which r=
eally is reasonable since the POSIX fcntl call only allows for returning a =
pid). I guess there might be some use in a tcpdump trace (but even there, o=
ne might argue it would be nice to see the IP address of the client holding=
 the conflicting lock along with its [probably 20 byte] lock owner).
>
> Frank
>
> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@kernel.org]
> Sent: Thursday, September 17, 2026 5:24 AM
> To: Roberto Bergantinos Corpas <rbergant@redhat.com>; trondmy@kernel.org;=
 anna@kernel.org
> Cc: neil@brown.name; prabhakar.pujeri@dell.com; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH v2] NFS: return DENIED in decode_lock_denied if we ca=
nnot decode owner
>
> ...
>
> Typically, we don't work around server bugs in the client (and vice versa=
), but I think this is a reasonable thing to do in this case since we don't=
 use remote lockowner information anywhere in the kernel.
>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
>
>

