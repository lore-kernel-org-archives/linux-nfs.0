Received: from mail-ej2-f12.google.com (mail-ej2-f12.google.com [74.125.228.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 456153B42C0
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 06:29:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.228.140
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789626568; cv=pass; b=cQIljhxJnHqisCwtLHvp+JBCXUdMilW7HcTZZSmAziZQLcCoupgDoMgLDqWP6xTDP8I+5X5OkadVJarB9Ts5WqovUHFi543GFE3QzEwBL1er2cLJTjdsLiz959qmcTXfI6DRqB1pE8Ucqi3668vxRRY3oisMk8Avk0Ks8NO7qII=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789626568; c=relaxed/simple;
	bh=UBMGKwSq1px3lW6LiRfASzBbguNZNBb50WlSoSAbP+s=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=XgdHKgh1X7hqj6O6kuS8pmYohICvtnHJ2PpPNCmrPEhoW3frDG3DJTUS35dC/RMe14SAiSiy217adN7pE45bQVMT0ljXduoPJwsd9tlX3h15bgRMsGqWnbWxum9DpkNjXhG9Ha6311pwm2DjamPxR2kjeO9Dd/F3ll7pkWb9B3A=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=fXmnKezW; arc=pass smtp.client-ip=74.125.228.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fXmnKezW"
Received: by mail-ej2-f12.google.com with SMTP id a640c23a62f3a-c29703cb470so73394766b.0
        for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 23:29:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789626564; cv=none;
        d=google.com; s=arc-20260327;
        b=gH8LGwkhj3jxr6x3KnJ8Vndrlm5qM5Ko4+mc0PGgxlhHxWC8P27LJ7OTPGcurr0RxN
         KMWyfx9R1zG8FEUfrhFdjSFXStkW5GweIu7vAuvtb+hW5Lh+AHrGt3an6vEWUrovgJlT
         +AjoVI7lYRs4fWRxTifnyPZbHhIfAlf1BDAlyIXsQYByQnAZrwBMwmxbh3cFNlL9SxPn
         Qi46TpYNYn7XldwTXgq1JYT9zcIr5JfEGms4y8G/pFzXf70Bu5Gox9RXlZ0fO5wr+GQt
         uUDT6ihbup7TH1sUYanZoXb/rtJWjAVtUdB/x4DwVJ67WPCaaDV9IfxubvN6rwWAv453
         tpzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=1LDSAUXFP1DLw8ZLs6ScJ2JQJKDoIaVmrytOlOr32xs=;
        fh=mutUDXlUNZdfnrHBO3lrIruyn/eg6/CYleU8H4PH6Gk=;
        b=tDlFmcGLxzDlPG4uVcOvpxtZzdawad/ohhiTdCFj7lCRB2y93fqZDIU0TpIl4Z9waI
         F2zB7hm/MggQa0UoEYR/62sJ1j6Nm5AUs9pLvBL++6lxeWIXj+azSsHflFUXPtkhLDab
         L7C1ddNZ+q6qwdijZUWzrqgU3LGir5OTSI3YqOU1KwcTehS71GmQlfdSipA/SAe82sYW
         xz9mxTjSUarfhVdb6rV0IJ+YC0YMQF/NiN2TqqQGZFIAoxRjlsUvfjfuEk4VentHZI9/
         QScLGV3uXbeOevZRWrrJI8Q0QXWIT/HrrVFbDfhWoCWS51URUrUqqhO81ilQR0kJTDXV
         xStg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789626564; x=1790231364; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=1LDSAUXFP1DLw8ZLs6ScJ2JQJKDoIaVmrytOlOr32xs=;
        b=fXmnKezWQHGEW2c+W00zNHEMkHJRxtsLrplPMGa2Za2kup83RY6AJKpnKqelpdyw4D
         pys/p8vRKc8bSbJree8uOwqNZguwgESVeNiekcrg4nuOhDiICsFsQzhxS723lTjg6h22
         9FeGuKEVh9UTEAcB8D3Xv0BjtrhnApJBgHr6/FMPwS9asD6l7+M/wYVpfvYpkyrZePdK
         ggYvcDGefkHV3wNli6WvAm2Oj1o4fstO/76FauxXmr9xfbJ9v0xG66Vdhm+Xxew9Oc9N
         mN5VTYcBeO6/xpti49r1qp92sYcm/mkfHbjIk5TcqCfmqTJjI22nrMulqJwetqj5Iek5
         lwsA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789626564; x=1790231364;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=1LDSAUXFP1DLw8ZLs6ScJ2JQJKDoIaVmrytOlOr32xs=;
        b=djrPpzBoWnUj7ZHT6wC8Fnau8EXYbc4TOHM3NM2xGOQi1/NBYVdFaVglltoMgQvUzU
         rAoL4++q4lcKr5jhuRWDF61+WITyLxw/nXWRkGG19WL/JNUs7k9sHHrO44eFi32KEM96
         qN/9nDLBJYhhY+ZAgqb69/KVUoFflhqTKgpdvctjZHrJKEfclJP82ll/iiDj1W/BHKhI
         GU2oIjxNSC6y3N11g7i1FfUwkA65c4rYqhU2iFVfkWrkGz+KjAyau2bwvyA2D6yrfbTi
         YpJAfRgwSYoZfCJJPjMRLeVwOe3OicRTOYNdpaCdOp7jG3iI7u8cCoSaqwFNae1+Dalb
         kgHg==
X-Forwarded-Encrypted: i=1; AKwUvByKfrmAniZLNxMAx2JUW5/0G/8KtqjINHpoL83eGerymc4x3ZUh9XKGzE62RNtuEPWxxsTL15JMSQs=@vger.kernel.org
X-Gm-Message-State: AFuF++nOG1zsuGNtIygWbN7u/lpFpTZxVgySvEQAUdsTWqrCWh6xBmir
	kjZqbbczIa2SG/8WllZhiSM9vOLS/Kxiya3xXUoxS/OYLSmOxliilhYgkuXcMWLlILsTsQu8Um0
	O+mJ/OM/8lteC9hipNrUE+xN7SEGYfFM=
X-Gm-Gg: AYBFou06RkbOVnK5eF45T3l9d7PMim6BbpWLxsBMn+nPTsx0Rd7odS88+HB6l5MFeHH
	8X/lOrDx9eO3wdbYDBIf4xLmKOJDhYqG1DBlneP4DjcckxYeFa+TnvTo5H6N1boJvLwcb6XufSv
	XWSpQoQXREjrFLiwOh4i+QkvVY0ZiPMg7CgQGEs9rVnSRW5VckewNXlokbnT/iL6W1BuYXPQ77B
	O5vmZGTK5ka0h5ebYtbJOqUVhnuPuda8J3GmyUTKQy39eUNQ3BhWRZJRdp5f2JfnbfqrSFom9wh
	j0iKV6n5nJnX4aJV9vuQDmdO0qPhMh8vxeyQCsevIB8Xmh0spo2FAajnvMU=
X-Received: by 2002:a17:907:6d22:b0:c29:f5d8:9c78 with SMTP id
 a640c23a62f3a-c29f5d89d5bmr138516566b.39.1789626564016; Wed, 16 Sep 2026
 23:29:24 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
In-Reply-To: <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
From: Lionel Cons <lionelcons1972@gmail.com>
Date: Thu, 17 Sep 2026 08:29:00 +0200
X-Gm-Features: AcwNN1WbuhlBox-R7Wt34W1GCYn-6nsONrYiY2Xq_DvGpAgQwlLAdwfZU7mGXK8
Message-ID: <CAPJSo4VAFGX9ndn2Q9XR6oBvgxRdm-QG1c8acGJY+3UtFMhEMA@mail.gmail.com>
Subject: Re: Need NFSv4.1 "WANT_DELEGATION" op ...
To: ms-nfs41-client-devel@lists.sourceforge.net, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>, NFSv4 <nfsv4@ietf.org>
Content-Type: text/plain; charset="UTF-8"

On Thu, 17 Sept 2026 at 02:08, Roland Mainz <roland.mainz@nrubsig.org> wrote:
>
> Hi!
>
> ----
>
> We're experimenting with a delegation-driven client-side
> consitency+caching model for the ms-nfs41-client Windows NFSV4.2
> client a while now.
>
> The original idea was to have two modes:
> - Mode 1: Get delegations (read delegations for accessing data
> read-only, write delegations for accessing data [a]) at OPEN time, and
> return the delegation when the file handle gets closed ([b]). The
> client only does buffering+caching if it has a delegation.
> - Model 2:  Do not request a delegation at file open/creation, instead
> translate Win32 oplocks into WANT_DELEGATION+DELEGRETURN. The client
> only does buffering+caching if it has a delegation. Server-side
> revocation of the delegation triggers an oplock break, releasing the
> oplock from the Win32 side just returns the delegation. This is
> basically how Win32 oplocks work on the SMB level.
>
> But in real life there are problems:
> - "Mode 1" only worked for small testcases. Real Windows applications
> typically change filehandle attributes or change ACLs after creating a
> file, which results in server-side delegation recall triggered by a
> NFS SETATTR, and after that we do not have a delegation. And there is
> no WANT_DELEGATION op support in Linux+FreeBSD nfsd to get a
> delegation back. Which typically means write delegations not being
> enabled and therefore no client-side buffering/caching.
> - "Mode 2" does not work because Linux+FreeBSD nfsd does not implement
> WANT_DELEGATION to implement this "on-demand delegation" model.
>
> Or short: For "mode 1" or "mode 2" to work we need the NFSV4.1
> operation "WANT_DELEGATION" to work, at least in syncronous mode (e.g.
> no CB_PUSH_DELEG support needed for now [c]).
>
> @Chuck Lever What do you think ?
>
> [a] Win32 also supports opening a file for attributes only, which
> means no delegation gets requested
> [b] Note that WIndows supports close-delayed files, which means that
> calling |CloseHandle()| will flush outstanding dirty data, but keeps
> the file "active" in the driver for re-use for some time (except on
> delete/rename/etc.). For the NFS driver this means that locks are
> returned, but the delegation+buffering stays untouched.
> [c] Technically requesting WANT_DELEGATION async via CB_PUSH_DELEG
> would be a welcome optimisation, because it could help dealing with
> files with high contention between machines.

History question:
Why is WANT_DELEGATION an "optional" operation in NFSv4.1?
Server can always recall a NFS delegation, but a way to get it back is
only via an "optional" NFS op?

It looks like a mistake/oversight that WANT_DELEGATION was never made
"mandatory" like the other delegation operations.

Lionel
