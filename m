Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F5E317A314
	for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2026 10:21:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.50
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787394086; cv=pass; b=WPMeUl6YBL/bTo4N72k5Nu8pI6HzxqC6pqlicz6cq2HycAIS/P+zist9xV/lmvA0emdEfGGfX2OdE6jWZwWoDwE1LPn1HcjVen3alh1LSRKwlmT+b7fI38Gg68mnxZQxKudpYWVEDWcNJ7YA43K2bjC0U2ciZY5OaP6rHohz2UM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787394086; c=relaxed/simple;
	bh=/REmArqAGflR08+GqMzRbxdUsrqkUc0EZm4Nwfpsi24=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=qUAYrPdp/+S43/U0qWmJlzJcitInFMb8dbGvwqUC38n0zkLcGCPsbO9DZyFpwc9d5HcjzL3/GC+2OB/rpK6oi3v7qKrl6oS1zqneQfmykbOuLtHvmLcWr2MPXUaER50pbLwOQSEOEWJcIDMEToSNVJofO9s7R//8YNcs+YQ0Pqc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=cKH+lcNK; arc=pass smtp.client-ip=209.85.208.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cKH+lcNK"
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-6a051b737d8so2476744a12.1
        for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2026 03:21:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787394083; cv=none;
        d=google.com; s=arc-20260327;
        b=Z58TwMm+wzF3xmDokes25tNaYGL3679frY+ZV9Z4rD6IjtJccfjbCOclZy5YyINKRP
         NQP7qdoLglD2gBzzrC4Nx2w4+QVf1GePuuyOoK1YvZ7xvV+tSO5ydlSlUc5CCYJfHVMe
         oIanOpp4NB6fXq59FHhLfQQVpqZeNcAalnKzvNJTGZCxuqY2dlkgr70G8AIwXuXvvEVj
         BD6itKkt+MCfeePuwt/bL3e7Z1okSOGAa2hsL7GEZch9SCfz20EHZSIR2ZuZ5bOH9EtW
         PO1nSX3HbfBeZNWvb1YyH0t8IxxCPa1+cXfqjdsSpd8hdaP5baPQ4RqyVJmPYAh2bLh+
         IpsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=6pk0qhrxFdQA3tThenrKug4RmzTweFzB5qVSaDfnu8M=;
        fh=/NcU3dRWxcdC2vw6yN5YhuqlrhRKVngwxgQuoLUqnXA=;
        b=fnUrp3w/Sxe33ke0dYmL7VFGW87Ro5LYTcBXdChwGyq3vaKnoTdITTRUnKuhH0IGsZ
         YK9ilH30hLcVMfK6zoyGwJLT659V9UgBd+ikvt225dP7+5L8kPwPZyhOeYpVdxcmoCxG
         HNe1+7tCIi77Dmi2uRqA/kl9oTXIg1JJnwA5926uB9AV1Nz+1fL0QIoBX4vHrdqlFNM1
         0XQ62LiOrhIYuEXlYNLn9bOfErvF35UuciW1FZ+RVrk/UGk5Vc0FMEnyuKj9KR9vT5jx
         aeesNdZs0e5RFcn72Mxtd6D0WHCQmj9QW++GNVPl+zHawmeVJank1jpW2EmIyQfcJ87Z
         k3Ng==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787394083; x=1787998883; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=6pk0qhrxFdQA3tThenrKug4RmzTweFzB5qVSaDfnu8M=;
        b=cKH+lcNKxabKRz00tGTWNuSTz+xDpDB8vIQtu6gvsxe3d3MMPn5O58sBNw6PTkf7eC
         tmPMUlq9zyPuYajAEfwgce5gsNdL5vC61ynUku7ulAIxCZxTriBmiwYAT9CX1W/0XqtY
         WDiEIchH+pdK8CNHB0jN+SziRupdUoXlo5E+sgKtApatIKK7DgdlO8BRpCYW567mq/IP
         GcDTM0mbg/PPL9WOVjip0iyGrFjo32H5VYITYL0COYMyVP2cmJ2YEmXYchjnDB4blvrP
         iKRu1wXpkxCSYsFkca1FJOytR+piNKDtKphX26QBPFob1u2ZuUV74xmbtgpWwaAMJgI4
         sSYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787394083; x=1787998883;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=6pk0qhrxFdQA3tThenrKug4RmzTweFzB5qVSaDfnu8M=;
        b=pHLCzezAw4TeQX8FVnUP0kxblkp7FTtvTJOOH19N3TZdeOWpvI9K96pDMoo8DwbpNG
         lYuDfbu/6bbX6ZkuUHAAuzDe2nLWTu3AykOelO7W/F8eB4XDzeWO9WAFZfAnUwiN+mZg
         e/I3uFFc9GHg0g00BWX2raIJ60YkBtLDGMv9DaxuGFKho05p/9HA/nsoTMkuxJGuazQw
         pn9cOBtJmsvL6kYWGdtEKGA1HkRvhk40eZPLA7OXXkrp4Riwk6pE+rHpLW90fVmXudOj
         sOwujr7BTdh2WMdXS2JVyiePYCfihMEa3HJuX49IqlWyAkIaFYFceSLBDjT5JenC8K5S
         pcDw==
X-Forwarded-Encrypted: i=1; AHgh+RqMFqw8+7bhm9RotTMQsdCPxpfvgBCkkOcoskdBXe68L1oPmXhRZnPUGG9SBF5dmAbblue4CWBA/Hk=@vger.kernel.org
X-Gm-Message-State: AFuF++lkLwGTebwqFWh2RIOcl8Ez34byaAeYPLFmdrbXovaMeeE6MgPr
	KMYCAs2W5d6EjHKJOUpNse356BdniYey7mvvLAeD9aLqvdkTKltpBjn6vV+5IzgTbp4HmG4LQ16
	83XCv2zHF+4pVqXADzHf1DmC0khnvxDk=
X-Gm-Gg: AR+sD13Lm36IUflOh7SMALW8a3V53EltMZcqu6vkdxWgTxeLmcroj3NILZowmOamO80
	vzyTxP8a6GRp40jt6iv7KZ4JwQGyJmx2McVnaQDD620L4n9mFKLjuvAOeKlhdeHGUWn1eylbHsB
	t5zTco82fRqiZHb7TI8DJEgoQoE2AeGcX7CofNQEkJaGy4susgYZXkEO6E5kWH+Dj59A8opSCWt
	lOgNt6yqPq/FDZagUTNC3TxmRYSJulYWOJN7+8dY/3buN02CuG4+T1chtPXSBPJG3HGzkniXuQR
	ge2cO0Bvpd8NzrynH8Cy4dyYDm+fBCShmydCH+q0D3707Q==
X-Received: by 2002:a05:6402:5042:b0:6a3:eb58:dcfb with SMTP id
 4fb4d7f45d1cf-6a42f1ddad2mr13653297a12.10.1787394083030; Sat, 22 Aug 2026
 03:21:23 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260818225715.572140-1-ameer.hamza@truenas.com>
 <aoVHBkmPNSRakbYW@infradead.org> <9ad95194-983d-427d-9a07-c9eb0891d1a0@app.fastmail.com>
In-Reply-To: <9ad95194-983d-427d-9a07-c9eb0891d1a0@app.fastmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Sat, 22 Aug 2026 12:21:12 +0200
X-Gm-Features: AcwNN1XzemKu-d2TUHxowW_SDTAK17OPxEP916mNVScXWxTH88lttphBtBvhGEs
Message-ID: <CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSD: Fix duplicate fsnotify access events for
 iterator READs
To: Chuck Lever <cel@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Ameer Hamza <ameer.hamza@truenas.com>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Christian Brauner <brauner@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 19, 2026 at 4:04=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
>
>
> On Wed, Aug 19, 2026, at 2:02 AM, Christoph Hellwig wrote:
> > Well, that is the underlying bug here.  ->splice_read should not
> > skip fsnotify events and nfsd should not work around this as
> > fsnotify is not the business of the users of VFS APIs.
>
> I asked for the duplicate event to be split out of Ameer's larger
> series as a backportable fix because there is clearly a bug here.
> But NFSD might not be the correct place to address it.
>
> Today the fsnotify event comes from the system call implementations,
> not from the splice helpers. do_sendfile() calls fsnotify_access()
> once do_splice_direct() returns, and do_splice() does the same for
> splice(2), while vfs_splice_read() and splice_direct_to_actor()
> emit nothing. vfs_iocb_iter_read() is the outlier, emitting from
> inside the helper.
>
> NFSD calls splice_direct_to_actor() directly, so on that path it
> acts like do_sendfile() and emits the event itself. That is why
> the fsnotify event counts differ between NFSD's two read paths.
> Moving the fsnotify call site down into ->splice_read would double
> up sendfile events unless the system call implementations stop
> emitting it at the same time.
>
> Jan, Amir, what are your thoughts?
>

Here are some thoughts and points for consideration.

(1) In this series
https://lore.kernel.org/linux-fsdevel/20231122122715.2561213-1-amir73il@gma=
il.com/
we intentionally moved the permission hook outside
of the splice iterators because we wanted to avoid calling them
with freeze protection held and also there were some duplicate calls
for this work.

At this point in time, the fsnotify_{access,modify} post hooks are
usually called
from the same context as the matching permission/security hooks.
It doesn't have to be this way, but it's a good mental model IMO.

(2) emitting many READ events from an iterator instead of one event for
the user's READ request is more noisy and serves no purpose to users.
In most cases (but not always) those events could be merged, but at the
cost of futile CPU cycles.

From a quick inspection of the code, it looks like:
- fsnotify_access() is missing in vfs_splice_read()
- the naming convention for splice_ do_splice_ vfs_splice_ is a horror
- we could make the low level splice_direct_to_actor() static and possibly
  rename it to splice_direct_to_actor_sd() or something
- we could export vfs_splice_direct_to_actor() for nfsd which wraps
  splice_direct_to_actor() with permission hook and fsnotify_access

Whether or not this is prettier than nfsd adding the fsnotify hooks
is a matter of taste, but I can live with either.

Thanks,
Amir.
