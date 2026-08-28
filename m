Received: from mail-ot1-f46.google.com (mail-ot1-f46.google.com [209.85.210.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D66039DBF8
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 22:12:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787955176; cv=none; b=BLu1f+If7yV8LT6xYQkWYKRoIrKR/0P1hDN5DmLcK2SkEZlDr73U/nuzZZLxilIuKluA4MCdsAOUYmi1rVUIy86VoVRWILfj8RZFMtiLZ3+O0PddPl+DrO4rcSm59rADIoKcYgVIawy3pvxQbD/obyFpgxhkvDLy1i0hfuop/Vw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787955176; c=relaxed/simple;
	bh=TUmm79BP4CF4NZjSHjc9ODvvyHPF0yCpU1Ji30GezsA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=SqaqyOOW2VZ3Vy7+3ZzLDjs+vWxH6fZNsqBYQremjpFUisRg9WxdSe3RZUsWTa43lY8n/gY7jIUTLFCW47uiAlzjkaNfvYUYBkUs9Fv+k115tC9ut/wZkrAC+BatXJhpXIv5SaCQCUQNf2BH2RFRcfVs7OMpVP6+0/zgsKKI8o4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=konsulko.com; spf=pass smtp.mailfrom=konsulko.com; dkim=pass (1024-bit key) header.d=konsulko.com header.i=@konsulko.com header.b=jm+3wavJ; arc=none smtp.client-ip=209.85.210.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=konsulko.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=konsulko.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=konsulko.com header.i=@konsulko.com header.b="jm+3wavJ"
Received: by mail-ot1-f46.google.com with SMTP id 46e09a7af769-7f0167e59a3so1004345a34.0
        for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 15:12:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=konsulko.com; s=google; t=1787955173; x=1788559973; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=PjupV3Z3MwayfOlBMl+CYawtfOAbm1Qy9xoQ6yqzKV8=;
        b=jm+3wavJu/QM9T5kdbxe5ky/1MFZ9ETaf+zJHansi46HlL3ekXqKiwoQ1jn7eBlGLE
         AaMTFgv7a2xxX3Po1Zpc5uhiw5WND+kcSgD8yX7PEImwmmU2VKu11COqvGKsAMv3c9K7
         SBAebfM+qReXEulCh6ZUAEEHePmseKe4HdzlM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787955173; x=1788559973;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=PjupV3Z3MwayfOlBMl+CYawtfOAbm1Qy9xoQ6yqzKV8=;
        b=WIR3SGD++dPVrT+XCXMLl7CIeo6/2p5BTHsUK0mucMjCzTGRUDJKegcMBjTSSkauXB
         aEFgWWuhmrYVi0RHTvCv4eRkcMasNXLHqAW4SPsmX/6UhNeDW4sn4QnfESdkHPbn5Iw7
         Fp7cRbfqboty9T7E4UpCsE7+TCoiqpHD3ht3cXhnqW6Fap7/fQQ0+OyjYrzDByzZiFJN
         K6qfpCmJoOb1EZr4MOVwL4bbEXn4EDjJi3eNpvD7t8JUCrr+QCsjwXzxYSTsGS6MwIWu
         E31gM+IyYc/NRH6/N8LDXmIHniEvgDxhNtWflHcNJ8wSlPGCc0GZUvPeWrpTS0GZHdA1
         p+bw==
X-Forwarded-Encrypted: i=1; AHgh+RoOmfWgRu4u9dlHGAUvMklCkiz6C3zced7UEQRL5hIAUYxONLtcZD5Y+fhUfD94buQ8jR70XcNNdiA=@vger.kernel.org
X-Gm-Message-State: AFuF++lulPoq90tQLX3MaYW9Mn99T3pcGgwb5VHnViQyQcBdrOez46Lw
	0kqTWkV7IRbx8YMBv5wm7AMta4pWPeZ0/pQgg2XCVHguYriRCoQW0ZTPkY0J5xJa460=
X-Gm-Gg: AR+sD11apNa/zn7Rs0OQZ3KiDafu4ztO4iE/haFM5ONQdsYYU2CQIe3KMm6UuDsygs3
	78TOQUzq7ZZVCxfuOHXGKTygNyOz69T9vdrvjB8KV0TcgmSz9dCFyL1fkSygQ6BBj8mdjxwGpI4
	kRhPc6TXpAHyfhPtMOPiDEig/bJV2p7h0zKasAxWguwnpZsk2erOY9nIFca2US/m4x92gkqbOe+
	ssbKC+l9DOJPQmyUO9iy3koV7rNcZDuz0Hwi//lMe48R+Nqqqe8rngHPa5utjj44zkGFKO81cxU
	q7iKb3+eOTwQzZYdpGDpkXOmQIohCkoULagybPcxqj1EbVwVpE9klFNP5x1NJNRWIT7RtY3lAVH
	ZmOZHr7pgA0Q/dPweuYbT6ACCk1qu1O68vN3oPxY6btl2tMTbB5u6x6v8rZDGZhj9903qUmPTlc
	s3ar8ZHJhuAL9sEmUG7W3qjpNYfGKv/0L2lGmoFJbyogATRdgixXv9ebD4eTw0vxXwcuV9rxurC
	OOGOWqdUYr3B2L1SsYPT3Wm3Jhb2IEO0jfTHngch2lzflxYvw7RuWDEnP852kqyQDRhtVFhH/Am
	G0DFq9Xtvw==
X-Received: by 2002:a05:6830:918:b0:7e6:50dc:6512 with SMTP id 46e09a7af769-7f4f238adb2mr12142663a34.6.1787955173287;
        Fri, 28 Aug 2026 15:12:53 -0700 (PDT)
Received: from bill-the-cat (fixed-189-203-100-56.totalplay.net. [189.203.100.56])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f4fa96ce0dsm2222852a34.13.2026.08.28.15.12.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 28 Aug 2026 15:12:52 -0700 (PDT)
Date: Fri, 28 Aug 2026 16:12:50 -0600
From: Tom Rini <trini@konsulko.com>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	=?iso-8859-1?Q?J=F6rg?= Sommer <joerg@jo-so.de>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
Message-ID: <20260828221250.GM3959812@bill-the-cat>
References: <20251210002850.318350-1-cel@kernel.org>
 <20251210002850.318350-3-cel@kernel.org>
 <apE90ZRZB8IW_AiS@jo-so.de>
 <178791679053.3510150.70411349578293852@noble.neil.brown.name>
 <91e02ca3-e985-47fa-aed8-0b50a5d7a3c9@app.fastmail.com>
 <20260828205116.GA266670@bill-the-cat>
 <a9a48faa-2663-40d7-86c8-ec2eaa967cdf@app.fastmail.com>
 <20260828211855.GL3959812@bill-the-cat>
 <a832bec6-fdcf-4405-b8ed-87418bc704cf@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a832bec6-fdcf-4405-b8ed-87418bc704cf@app.fastmail.com>
X-Clacks-Overhead: GNU Terry Pratchett

On Fri, Aug 28, 2026 at 06:04:39PM -0400, Chuck Lever wrote:
> 
> 
> On Fri, Aug 28, 2026, at 5:18 PM, Tom Rini wrote:
> > On Fri, Aug 28, 2026 at 05:06:14PM -0400, Chuck Lever wrote:
> >> 
> >> 
> >> On Fri, Aug 28, 2026, at 4:51 PM, Tom Rini wrote:
> >> > On Fri, Aug 28, 2026 at 09:27:41AM -0400, Chuck Lever wrote:
> >> >> 
> >> >> 
> >> >> On Fri, Aug 28, 2026, at 7:33 AM, NeilBrown wrote:
> 
> >> >> > U-boot has
> >> >> >
> >> >> > 		} else if ((rlen == -NFSERR_ISDIR) || (rlen == -NFSERR_INVAL)) {
> >> >> > 			/* symbolic link */
> >> >> > 			nfs_state = STATE_READLINK_REQ;
> >> >> > 			nfs_send();
> >> >> >
> 
> >> The "deployments can't be updated" also doesn't make sense: if
> >> they can't be updated, they won't be able to get the revert
> >> either.
> >
> > By deployments I mean U-Boot deployments. It's notoriously hard to
> > update firmwares most of the time. Some testing labs refuse to because
> > of the value in testing the firmware most people likely have deployed
> > rather than the latest and greatest. So most of the time, it's never
> > updated. Can newer systems take advantage of good and specification
> > following update mechanisms? Sure. In practice? Only maybe.
> 
> I'm talking about changing NFSD to return NFSERR_ISDIR, which would
> be picked up by the first "if" check above, which already exists
> in U-Boot.
> 
> That addresses the regression and can be backported into the LTS
> Linux kernels that have commit 0ac903d1bfdc [*]. It does not depend
> on making changes to U-Boot.
> 
> Since the problem was reported on linux-nfs and refers to a
> specific Linux kernel commit hash, I assumed the only thing on
> the table is a code change in NFSD.
> 
> 
> -- 
> Chuck Lever
> 
> [*] AFAICT, the only two LTS kernels that are affected are v6.12
>     and v6.18. The stable kernels (v7.1 and v7.2) would also be
>     impacted.

Ah, thanks for explaining more, I hadn't quite followed. Yes, something
that doesn't require changing U-Boot is good, thanks.

-- 
Tom
