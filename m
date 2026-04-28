Received: from mail-ej1-f54.google.com (mail-ej1-f54.google.com [209.85.218.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A23046AEFA
	for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2026 16:12:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.54
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777392761; cv=pass; b=Id0+dhKpxJ6bDCtyKor5zGtzZEC3k2PreDyCz/wB6QEZqb8SoZTjjtGOKk918cY2UcSsu7P1HeZzWm+j1KnC4EtOQi086DAXC9p8n1C7/XqTqoZvaljD0zQR5tX8oM6aOmIC4s4STUX2kt8k6vbY7OwqT3Q3kkfWiYOg0iM4pNM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777392761; c=relaxed/simple;
	bh=q6JgxFyLvJCahXylzyug/1dX1ICrpJy19p5dtVuDOXg=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=n0Zt6jpjbnGFaT7OBky6x26pi6/3SDvTCvmJG5dX2iuqAxmSX470+sQcq5uEt7rW2dFzthnBL923bBWcX1rSrfZtSzsW1G7INgoUj+Eaw9AQajWkkXy5wqOGe/bsUN0ZRpAp23AMmiey10v0kBc9hjx8wQMT/cbv6jM27kMX+yY=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=YtwWsaTf; arc=pass smtp.client-ip=209.85.218.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YtwWsaTf"
Received: by mail-ej1-f54.google.com with SMTP id a640c23a62f3a-ba51e69988aso1584118666b.0
        for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2026 09:12:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1777392759; cv=none;
        d=google.com; s=arc-20240605;
        b=Xj2hGe46fx8a85FWKSbb8cyRIjuezOLKugeLLeW4nvERFgXMsdPhgZXlD4PNG/NKxw
         SM4kN3hAZ5bEbiy7ipwt+wAwx0tWUgTXzWS6V6w3LPwWW5bsPfBbZ/tj7z9voIOHcs//
         6L6rIJLHD6jjtkzPxlpcrNOz9S/CR1D7x+wUZK2GsPcDOiYdgE4y8dJcEHDBwDgJ/EQb
         OaTOqv4ODcuvproo9YIVcPSOuui+1mDuWYMFWQNVuPjbYCLd4JQVXxFU09JqqwPyXIe6
         37uCv6ziNOmUPPRV6O5yJ2aWVYFncmScnU0k4kVqywDCpXvcR6UQqolpED24i53brVaD
         jQOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=G8PidlKSHO0r02Iwhfxhmz5vcZ6K78QPaLAA3PHEonk=;
        fh=THd1KWM5b3M9IAF8IDYIIAuZOM//KqEqD5zI14dNBUY=;
        b=Rdd3ShjecHyS9vEb4hIXI6w6esdlzKIagiIIc1fqoM3bjLN6X2/oAuY6iXXfLWAGgU
         DOdZ5EAOxGNTCG4u15RZu4Ud2o/H+X4f3Mtp2dIjfuQHXTgFJOdS8wvAwWJH8C3T8cqQ
         q7GLE20pdWz+fkbRQXxSW6KItmF9nEEN0kyxSPrPS4T54eSDjU3NmDTC7B0kfdhYFuXo
         z2qYfiMI7qR1lJNhGr1rba+Chm0C4a0paKLOBQ0BLpS/CGdCBBNxfcyPStyOvdVBpxRs
         utJzxaUfyPyG3ozOdu224pCKxlsrhClPw35TczsHIUqodg+hHMY5kHG3tWjwHSzuXs0d
         7HRQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1777392759; x=1777997559; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=G8PidlKSHO0r02Iwhfxhmz5vcZ6K78QPaLAA3PHEonk=;
        b=YtwWsaTfWEjXVyUzSlvUjUwlTQmsDIAnRThkbQwtw1zXJugfWD0mwtZgARufTDAhVy
         CxpmscJ2Z04rfuiTYI4nGuQLgvxh0+Dt4NKpU/ne6SVn3hQX3WXG4pqcYo/D180LU4A5
         oYEpUTco9bvaxGOvueOHyMP/EHmdbjy0ZTjs6EQWk7cMSU49oIDXdSCtOPhlBFoLFc+8
         8IF2ffdrAm1aviqCvS7YEm3gn79pbKq6HeAQcqVAwN14o16onpdOKkyTEL8kzhSBC53p
         4c19jnqyM8FTuOGmW10WYPFmXOSMCg0vwka1RTLF0kQXI6P7kYHuPD2GkNtFq3B+aCPi
         lVFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1777392759; x=1777997559;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=G8PidlKSHO0r02Iwhfxhmz5vcZ6K78QPaLAA3PHEonk=;
        b=f3LXR4RPRZWvFWKqOkq/T/yVlQGLmAgsnTZ9SMohTjLFr4JlCGDvTOB3On/xLYVJc+
         EqmjmYNHLAOTsmAiWvpIQ99DFurfVk7W60vF7TQ/LqlpwKvqtZBnybpkzEpYexhw1M3p
         Ob9pqs9ACIiMpC2dwOt+Kb++CL8Z7P02cWWWEv5jvmELJDdWemdhCppHE+3DyHiWZnhX
         ZnoMv1Xvfwx7DqdQbZYlgsznKmlqeo4NU5k9JBuI6a75wtm7Skf5egMQXjDyg0Tw4shs
         W4InIDL4BZXBGZZHsIa1Y91v8yQc0Xn2lhr24R/b8H8fOJtH0u+Cr/9Y3CqhFIfmr3Zc
         k5mg==
X-Forwarded-Encrypted: i=1; AFNElJ94+oyMe0O6rosVmRUU7fUZL1pD9PeicXqeznBdA0A+Y2b10J6y76WTgG2ZDk/Qkq2QITNLgk3HXQg=@vger.kernel.org
X-Gm-Message-State: AOJu0YxC3P20eV80svPZOII4KfSHc6qOnr/myf4kEzkd1rpKwcYBzVcX
	sGUO6HilctmlLr+Iq4I70k6yQG+A0m8Z7qqZSV1GoKryanVfqZqIfVIqA3sOE8MG0WrWzAxs0yV
	Sj8VTDOAjg6WZJdAqWsHb39u2erUejvg=
X-Gm-Gg: AeBDiesDoc/AcR7LFU4A/EgD825mVPf1iCHmER2+rSmOGU0p0+LC25kBPa4N9Gip9so
	wwFI6iXdHqOnvSL+1xm5yaFukpQIZFBYcwF5vSM07QTBxvES3uhMqXaYF5SGI5PRRHUT9qRfzxr
	qodWNebj73g3hoVYA5S8/LRjH9ra/W/sff9Nm6sENfH/Z3Z+bCI61Vphkys3Czazfw+wtvy/XF6
	vZZ4x+gnIPdsbPq9F7zvrjiT//aog58vG/TuzljstGuGyOnOm04qoGwZWEt7zzmxuuUuJJeGak4
	dBLbLDpK98D8pSJr
X-Received: by 2002:a17:907:8714:b0:bae:8734:18b4 with SMTP id
 a640c23a62f3a-bb8023bc02dmr171881566b.16.1777392758324; Tue, 28 Apr 2026
 09:12:38 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CANT5p=oV8kcE6hXPoUVQAYGaiz+2OERoSRLAS6X+q9KJ_8w8YQ@mail.gmail.com>
 <438478a7-c965-4a2a-9c4a-84b5f77d6dbe@samba.org> <CANT5p=ortwT7ensa+kKoCa=wMnGETpqaQuBnhDWMSNu82KsqFg@mail.gmail.com>
 <e248f3de-bbaf-48e3-9e86-0beb9a789556@talpey.com>
In-Reply-To: <e248f3de-bbaf-48e3-9e86-0beb9a789556@talpey.com>
From: Shyam Prasad N <nspmangalore@gmail.com>
Date: Tue, 28 Apr 2026 21:42:27 +0530
X-Gm-Features: AVHnY4K2XjlTsTSCHJLslIA3lI_-DAhznUe5mx_MQp1-M-AJVwKvcSVDlI1FDuI
Message-ID: <CANT5p=rt9V8Guiyt_H_Y8g_NEu2ZgHgbYLGM1CBcgoAZbzjXsg@mail.gmail.com>
Subject: Re: "Intent" of VFS lookups
To: Tom Talpey <tom@talpey.com>
Cc: Ralph Boehme <slow@samba.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	CIFS <linux-cifs@vger.kernel.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 24, 2026 at 7:11=E2=80=AFPM Tom Talpey <tom@talpey.com> wrote:
>
> On 4/24/2026 9:20 AM, Shyam Prasad N wrote:
> > On Thu, Apr 23, 2026 at 11:13=E2=80=AFPM Ralph Boehme <slow@samba.org> =
wrote:
> >>
> >> On 4/23/26 7:01 PM, Shyam Prasad N wrote:
> >>> Wanted to understand if this is a problem for other filesystems or if
> >>> it is specific to SMB protocol?
> >>> SMB2+ protocol mandate that open call specifies if the file being
> >>> opened is a directory or not (regular file).
> >> sure? From memory (though the logic has always kind of escaped me) if
> >> you neither specify FILE_DIRECTORY_FILE nor FILE_NON_DIRECTORY_FILE th=
e
> >> server is supposed to open the object regardless of the type.
> >
> > Hi Ralph,
> >
> > That's interesting. The spec does not seem to define this. Perhaps purp=
osely?
> > Will try and prototype a change to verify.
>
> This would be filesystem behavior and therefore it would be in MS-FSA,
> not in the SMB2/3 protocol.
>
> MS-FSA does indeed specify that in certain conditions, an open must
> succeed on a directory even if both DIRECTORY_FILE and NON_DIRECTORY_FILE
> are false (page 60 section 2.1.5.1):
>
>   If CreateOptions.FILE_DIRECTORY_FILE is TRUE then StreamTypeToOpen =3D
> DirectoryStream.
> =EF=82=A7 Else if StreamTypeNameToOpen is "$INDEX_ALLOCATION" then
> StreamTypeToOpen =3D
> DirectoryStream.
> =EF=82=A7 Else if CreateOptions.FILE_NON_DIRECTORY_FILE is FALSE,
> StreamNameToOpen is
> empty, StreamTypeNameToOpen is empty, Open.File is not NULL, and
> Open.File.FileType is
> DirectoryFile then StreamTypeToOpen =3D DirectoryStream.
> =EF=82=A7 Else StreamTypeToOpen =3D DataStream
>
> There are a bunch of other cases involving trailing separators, etc.
>
> MS-FSA is, of course, not the only filesystem type which can be
> exported by SMB.
>
> Tom.

Thanks Tom. Will try some experiments with this.

--=20
Regards,
Shyam
