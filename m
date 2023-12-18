Received: from mail-ot1-f46.google.com (mail-ot1-f46.google.com [209.85.210.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15B551118B
	for <linux-nfs@vger.kernel.org>; Mon, 18 Dec 2023 08:33:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nU4RvA84"
Received: by mail-ot1-f46.google.com with SMTP id 46e09a7af769-6da579e6858so1941928a34.3
        for <linux-nfs@vger.kernel.org>; Mon, 18 Dec 2023 00:33:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1702888407; x=1703493207; darn=vger.kernel.org;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=w1Gou9zvkvaC7gGTpeZcRWq0JlXWVx1/3szDE2LrHe4=;
        b=nU4RvA84t93a1nKGLNB8UojTuEN/YYhRzCswxQI75feTyQd5ErGd30qGpxxVoZgDbP
         My+QdCqDLT/TsjKxkTrY7jzIXa5xy8tpHHuA/gHgzyi8weWQdG9iy81Z0jywolmTJgOi
         gjqIkQud50/D+Sy2JkqzG/+2hAJxEo31FPbbuenAep3mJzXmOVMqHkHy+7+W9ztGaHm7
         z3FDvob1RgkXXdSBfbgo0ndyWapy6Kd6GmXsVQ8GqGCezezxSwxYCe8GH/Ye0xTatV1r
         yCvnS21FW2u+g85phOFV6fgJ/cJs7Nu7EQdeAr1iL64h1JxbZ6ZtXE3o+VzMhq2V5B4l
         JsEg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1702888407; x=1703493207;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=w1Gou9zvkvaC7gGTpeZcRWq0JlXWVx1/3szDE2LrHe4=;
        b=iQD3HfdjFDGnbAo8B7V3OrOMhe12MrEfxpD4iiW2blLHseOxez+Ronl7dpMMulL4ho
         cVD/pMnNzqa/Y/ZLpvD57uJ+92yjZegf2rnBRYM31Np8wITpNWE6KDajXfvuOe4klz4y
         w+GbOzeGfBPv2VE1V74Uh3VoVr4q2PV1JPNs/plS9F1Nr141KjG9FMsfCnUZ1NwwPVlZ
         iPVEyuyPkZcKx5fPE/xR2z1inRQyzCOx6mCYqcAxulfE9L8/Z/qQ+yaWUoyLF2WDq4z9
         efR6cCAWZCB6oR1i5hj/L86vtVk+rLfpRpI8nIlxE3sjbyHccJYDkN+kcJOu7MzmbS8d
         vPSQ==
X-Gm-Message-State: AOJu0YxyjcyRcYmxKgOj5OBl5XXLsz99PKuXhq9oguPr+pkpn6adwm09
	D/Gh/yhfF6WtqoG11yoLt3bhsLP8e7avsLe0wiDrxDDp
X-Google-Smtp-Source: AGHT+IFZBWfy0HFqIRYGvCuA0o9VyLfDEUhUzdLQIs9xrc4dbQgt0fObzWBnTc9Ym1e1fi50dU29nlQ+Vvzmd159kVQ=
X-Received: by 2002:a05:6871:d10c:b0:1fa:ed79:4cc4 with SMTP id
 pi12-20020a056871d10c00b001faed794cc4mr18855406oac.6.1702888406917; Mon, 18
 Dec 2023 00:33:26 -0800 (PST)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CANH4o6PeiV+ba0uLVzAnbrA3WtG8VSkvjA1_epfLCVyH-r-pJw@mail.gmail.com>
 <DBD9B468-6FF2-4806-8706-EE679BF69838@oracle.com>
In-Reply-To: <DBD9B468-6FF2-4806-8706-EE679BF69838@oracle.com>
From: Martin Wege <martin.l.wege@gmail.com>
Date: Mon, 18 Dec 2023 09:33:16 +0100
Message-ID: <CANH4o6MGLTCYuDBZfyrDn7OpD=HcUG9KcY8Qhhv5mzHj4Jr03Q@mail.gmail.com>
Subject: Re: NFSv4 alternate data streams?
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 30, 2023 at 3:03=E2=80=AFPM Chuck Lever III <chuck.lever@oracle=
.com> wrote:
>
>
>
> > On Nov 29, 2023, at 10:59=E2=80=AFPM, Martin Wege <martin.l.wege@gmail.=
com> wrote:
> >
> > Hello,
> >
> > does the Linux NFSv4 server has support for alternate data streams?
> > Solaris surely has, but we want to replace it. As our Windows
> > applications (DB) rely on alternate data streams the question is
> > whether the Linux NFSv4 server can fully replace the Solaris NFSv4
> > server in that respect.
>
> Hi Martin -
>
> Linux NFSD does not support alternate data streams because none of
> the underlying file systems on Linux implement them. Very much like
> the HIDDEN and ARCHIVE attributes.
>
> I believe Solaris and their storage appliance are the only
> implementations of NFS that do support them, since they have
> implemented streams in ZFS.
>
> Instead, Linux NFSD implements extended attributes (that's what
> our native file systems and user space support). I realize that
> the semantics of those are not the same as stream support.

SMB server on Linux supports Alternate Data Streams - why can't the
same be done for NFSv4? Otherwise we're stuck with using SMB

Thanks,
Martin
