Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793016581;
	b=BU3Tn+rqKCd1UjmUA1eKOA9uNsxH3/MwZxqH0Rb96nrmt0cBvgFmiUiQE/GZO3J8WqHh
	 h754PVcz3Jy0bD80L17B6CoRkhdS7hhiz4POZpl41ufYLCZBGl2wSMKPL4xoFQUHJkndi
	 6ZQDOlWeWB+VmP2ap4EwKdt0RlcEEN42MD9fU5PBhYtKr2sQ/OWpOp4dm0NvOSsp8lgPP
	 aut4vyQRC17zpnJkNyLl9KFVxkntuRJAQdBZAysy9Y4gxWtwwNjxPWvYlPC25KK3dZtyR
	 fqTZHlH9ypKlWK5kh1q0wqK2tv8QYlnLrdZbxapuUked0TuroL8F2R6u1a+45/A6Xng==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793016581;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=nrzZwmbiTICzxQaTpBGGNc1jTSBru89vupNxwMA5qvc=;
	b=d0y6jpq72byGgAT1JiY8aulGtYGVF3VSxuMSIwUemuwp61DrnOZgiak6QvcPOV8/DHAv
	 9DKQeXsnJZNJuv5CqlAjDFEVFBNxFbkB2dzrDJZUTmHw/v+jBgGYavX3sq0W5NLNRvNvs
	 jGpBxWUiWzAZq25f+ArrjwdJ/KshPMIZ5ukY6u1Np++p2MPb0cs/htI2VoCqCThWREVTQ
	 lKBb+UlMrRfMEfkaEQHYf1hkD8vLZNlvji1bfnCs2OCvmbtBZg3s33OuXvMau3X1GMbjd
	 FVLaT0xdarB5Nf4JxLHqbX5Jy6V5sPvnaOpi+AjOQiCkrBelDnfXX/PSsvxLex8yugg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=bQ5f9cW1;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b="rXCi/AXw";
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF83760A261F
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 12:09:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EF83760A261F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=bQ5f9cW1;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=rXCi/AXw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1793016579;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=nrzZwmbiTICzxQaTpBGGNc1jTSBru89vupNxwMA5qvc=;
	b=bQ5f9cW1pjZkjs6HvJlEGsHeikldWmvZ826RwSFXsDqWGaaVoRJrQjt0KUq6W23Z/dxMtb
	aZh8oBqwZYf/B1thv3+Xhta+SqDxJhvcmO60qX/V0O3Dlffvz4Fp8wvx+gjfgD2V0QeyXA
	AlkBxQjgObO0gHYrgGLhCat2JJVUmp0=
Received: from mail-dy1-f199.google.com (mail-dy1-f199.google.com
 [74.125.82.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-146-vco_ZstjNHionuda9RE-FQ-1; Mon, 26 Oct 2026 08:09:38 -0400
X-MC-Unique: vco_ZstjNHionuda9RE-FQ-1
X-Mimecast-MFC-AGG-ID: vco_ZstjNHionuda9RE-FQ_1793016577
Received: by mail-dy1-f199.google.com with SMTP id 5a478bee46e88-3692c5b061bso11149768eec.1
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 05:09:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1793016577; cv=none;
        d=google.com; s=arc-20260327;
        b=fz7UckXPME3UTmvDZ5chP4Rvph0FMpLq6wy0iX+9eg+hx1zPesPzm9QlUxY+5VDyBG
         Hu6XwhKLirjP2ZqcCGRLKKauwPUWXkTDiP5Y8ssNjv781536wx8P8p3M5cA/V8bwT9L3
         KWQ+XFYW+LKat+aAeCxHRBA7fk2V637MvxI6TTX8P4GRL4KbNygtwDW7ffWD6f1q91Pl
         jTNuR962z3hx6+8bYO8xz6dMP3ELkpTQ4dUNYtib5XSTLQGawQCQuSJE0h27jiLHSJLh
         B2oPn9tiT/M4Nu/l0O6QhxSWWs0M8WQoZcdvtLR+7NVo7ASo00dB63QKysl/6F41MN2j
         gtsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=nrzZwmbiTICzxQaTpBGGNc1jTSBru89vupNxwMA5qvc=;
        fh=XRq347533adRWY5otFq/Mnill6zxBelsPXGgpap39vQ=;
        b=lmYspxWmMV2YTxwoLWZC7zPNOiLQJ6H5YzpqBxL9CIyKVx3YPm6DARqUnlsDaQphLF
         96WrfEycUPom8+Dq9xB/o41f8N9XuSGEmTo7NHuewr18uGjvdDk8hIZFVF3L7cZ4QxtK
         mZfHnKXI3uuR8QgiELNLp/KBsG9r8/OtaQj73bBlERauqHSAQ7pyUqZdXrehLpOm4suu
         +5GJAQuKtWOWqANSiVdgxIzAIJvJzanT+B6vaPiyfiOPipCuJLJjojDZJLs1uviiWaLr
         RPY3CJ6GrdNbENADIu/tzsI2hTK8sOJX5dC7ek5H0VS3+xtP95DoAsCrwMpguqkI2+Go
         CVFg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1793016577; x=1793621377; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=nrzZwmbiTICzxQaTpBGGNc1jTSBru89vupNxwMA5qvc=;
        b=rXCi/AXwrO3tWOwe10aLDupnsWRuLF3sWjUaa+m4LD05fU8q8ESWHyQX4b2jdgTlor
         LKiSSIejHGNPrs2wKhC8Tc8O5+meXSUc0BrWPee8diKGWtKXRLfAO3ueVIXLSfPNE0kN
         fq8TP/0ccShBPaxxVJIvOEGAJhYghlZmkkjC/0dy7d6UeUezBVcWlFAHk9IxZKKgmcgt
         CyfPgppYKGYCmZ9IgkI0evUqZplZIKEnqeT/vWZSfd4u/gLSsVqC5m8A/FrJxxusqQIn
         lYIPk9moKo2gPsPnE/3QYtdPbL+hMdgs8xEnt8oKwRf9DGD8UMSeH6mQgAPPqt0MM0Pj
         pcFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793016577; x=1793621377;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=nrzZwmbiTICzxQaTpBGGNc1jTSBru89vupNxwMA5qvc=;
        b=eIFmrCkTyIUR90r9pTKznSu/xQRdIfDonS2Ydz9zxwNyb+iPB8j3PCxir2i7+g9cOx
         euQUKqYAiSXlTdj7tpBhVsJJizMt8Am9lksZLrU4mOyuJnWw0q0oeYUKL23x+B69xdFk
         ZSc4Tqfl67IWZnkRNUphv6yHIV0fp/EXarLhh6K/5HT0KHkJWb+Z1yLo0Rf3ffha8vq0
         /pVhNz0sG2mqTEFmoyVSmnpbGR8MA9eR0rTL8nZW9yy5e99fEMMN+n0otdCSPlK3WT2o
         2lErI3DC9G3AcpyvySOfbDby+kDjHUUSKkMij3hqD558EPgm0Q/1Hi55Q/l2tpITb3lL
         g/gw==
X-Forwarded-Encrypted: i=1; AKwUvBwjQ8cE79T4omJfU/zjoec4Cmog7Aujfan3FrzzHVYU+wfmC76TNf/V73S5bnWfYkita/fCREdC3XE=@vger.kernel.org
X-Gm-Message-State: AFq9FYJxr03rLz4fb8U/JcZuhYvSGMueg0VS6jzqzjEeC+Cq/0+/HA43
	m96kNlEDmWDuScwdfqV9FrSgKeLYntZCKWcOWXP2HZu4hfevmFvJwkzpQ+85Q5UFAV/wNKIUdba
	MWa1mzqQE4TTYkNrmUQPGQXHDChJ05V5XPMzH9CgTkMD63O14W9FF4Hf6Ixwbn7Y0JRSsekg5R6
	zNWkI1yGriad1tUQYzWQXYZvuenVnGhTFbSdZ5y7fm10DNEZE=
X-Gm-Gg: AYBFou1UKzdetQgoQ20wqkp4R+eyP1SDVMEKwEEi71esA0t02Jtoda8q2XFdSz+0vPK
	e5p+PVej6NfnJ/otr2HzBWiVXxRsxE3TUuIl8dTz9M69yyJmI0U4uHmIK3p3Y8+XiDxx1xM4qm1
	RTo+cOBjVENcVA2U4xI1eptYewzRrprgbA//XdaGwRxm1kW23EHVViEFcP
X-Received: by 2002:a05:7301:1602:b0:369:fd32:79fe with SMTP id 5a478bee46e88-369fd3294bfmr5007208eec.17.1793016577207;
        Mon, 26 Oct 2026 05:09:37 -0700 (PDT)
X-Received: by 2002:a05:7301:1602:b0:369:fd32:79fe with SMTP id
 5a478bee46e88-369fd3294bfmr5007178eec.17.1793016576598; Mon, 26 Oct 2026
 05:09:36 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20260902133554.28863-1-antonio.feijoo@suse.com>
 <CACWnjLzVeXAfVWgg_YTqtNTDd7LXSkM9dA0znwdPLY=4226bbQ@mail.gmail.com>
 <1925D89E-8A84-4FE3-95BC-93061E6578BC@hammerspace.com> <1015823097.11117914.1792766124992.JavaMail.zimbra@desy.de>
In-Reply-To: <1015823097.11117914.1792766124992.JavaMail.zimbra@desy.de>
From: Roberto Bergantinos Corpas <rbergant@redhat.com>
Date: Mon, 26 Oct 2026 13:09:24 +0100
X-Gm-Features: AclHuK-6GMPAFFtFccR9RZYJADau6Vb2EhlVJL5KSGFdtkr4RZ9whD1d77HtksY
Message-ID: <CACWnjLzZ1Xb-YABbSSJxj_Rc=WAPfxHDtD52V0VJbPQs3ENErA@mail.gmail.com>
Subject: Re: [PATCH] NFSv4/flexfiles: add a soft dependency on nfsv3
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>, Mike Snitzer <snitzer@kernel.org>, 
	Antonio Alvarez Feijoo <antonio.feijoo@suse.com>, linux-nfs <linux-nfs@vger.kernel.org>, 
	Anna Schumaker <anna.schumaker@hammerspace.com>, 
	Trond Myklebust <trond.myklebust@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 23, 2026 at 4:40=E2=80=AFPM Mkrtchyan, Tigran
<tigran.mkrtchyan@desy.de> wrote:
>
>
> Frankly, I think this is my change that has introduced the trouble:
>
> a68c6fbb638a ("nfs41: drop dependency between flexfiles layout driver and=
 NFSv3 modules")

Im not sure of this, that enables flexfiles when NFS_V3=3Dn at compile
time, but i think it does not prevent
the actual hangs at runtime. If i understand this correctly the hang
requires nfsv3 not loaded at runtime
(which can happen with NFS_V3=3Dm) + no MDS fallback (7a375cafc14e) +
i.e. unprivileged container.


>
>
> ----- Original Message -----
> > From: "Benjamin Coddington" <ben.coddington@hammerspace.com>
> > To: "Roberto Bergantinos Corpas" <rbergant@redhat.com>, "Mike Snitzer" =
<snitzer@kernel.org>
> > Cc: "Antonio Alvarez Feijoo" <antonio.feijoo@suse.com>, "linux-nfs" <li=
nux-nfs@vger.kernel.org>, "Mike Snitzer"
> > <snitzer@kernel.org>, "Anna Schumaker" <anna.schumaker@hammerspace.com>=
, "Trond Myklebust"
> > <trond.myklebust@hammerspace.com>
> > Sent: Friday, 23 October, 2026 16:16:32
> > Subject: Re: [PATCH] NFSv4/flexfiles: add a soft dependency on nfsv3
>
> > On 23 Oct 2026, at 8:30, Roberto Bergantinos Corpas wrote:
> >
> >> There is another problematic case for this problem : if an
> >> unprivileged container attempts pNFS I/O, SELinux may block the
> >> request_module() call, leading to a writeback hang instead of a boot h=
ang.
> >>
> >> Having the module pre-loaded at mount time avoids that scenario too.
> >
> > I think this is a stronger case than the nfs-root, which already requir=
es a
> > sysadmin to have knowledge and desire to configure the client a certain=
 way,
> > and can certainly apply the work-around.
> >
> > Roberto's case would look functional to the admin, and the failure woul=
d
> > happen later and be difficult to diagnose.
> >
> > I think Fixes: 7a375cafc14e (7.2.y) is the accurate tag, though - becau=
se
> > before that the -EPROTONOSUPPORT would fall back to the MDS - it gives =
the
> > WARN, but doesn't hang the system.
> >
> > I also think 7a375cafc14e also needs a follow-on fix (Cc: Mike) - becau=
se it
> > now causes permanent failure cases to retry forever- we should probably=
 just
> > fail the IO.
> >
> > The last thing here is that the MODULE_SOFTDEP is just informative, it =
only
> > advises modprobe and initramfs builders.  It not going to fix
> > CONFIG_NFS_V4=3Dy with CONFIG_NFS_V3=3Dn or m.  So - I think we should =
just make
> > flexfiles publish a hard dependency on a v3 symbol, which fixes the mod=
ule
> > dependency directly, and also fixup Kconfig so that there aren't unexpe=
cted
> > build failures as a result.
> >
> > My 2 cents,
> >
> > Ben

