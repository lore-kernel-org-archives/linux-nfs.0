Received: from mail-oi2-f1.google.com (mail-oi2-f1.google.com [74.125.231.193])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87B3E288C96
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 21:18:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.193
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787951941; cv=none; b=bUDmcl/ae+SIK/EBrX7yM8re9zIFhrcJeXN1JaGArEiAproy9KIf3PfG6y2oxhWd4V22DvtfXB3Sa+ADd2E3mBl7o99JzjJXbfbg4Z9vBuvYR0eu//YqYJyFlh9CGPNfL4KOsgCZEltdiv0nMx/qAQLKXPPX4HDKR+7ELPwJ960=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787951941; c=relaxed/simple;
	bh=vTgq1cZLmumnIlm38woD3ErdTltluFmhhpzkIii/5ik=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=mgL8z0V2+i0eeRsGQv4iYwIqfgtRepXMI73zJXAWmR2kW5N93AcgShlenNJo10PQeKDbWlOdSnxdB9VsDl6s1lSDOBmGKo8zMuAk5bj1itbbhLoTmsInHG3pBwHO6n0sP2tfj1x2rC0GpGzJbLWf27foBPF/JfmeYv0Y/OAuCdQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=konsulko.com; spf=pass smtp.mailfrom=konsulko.com; dkim=pass (1024-bit key) header.d=konsulko.com header.i=@konsulko.com header.b=g2xUXjQt; arc=none smtp.client-ip=74.125.231.193
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=konsulko.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=konsulko.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=konsulko.com header.i=@konsulko.com header.b="g2xUXjQt"
Received: by mail-oi2-f1.google.com with SMTP id 46e09a7af769-7f4d65b4725so568995a34.0
        for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 14:18:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=konsulko.com; s=google; t=1787951938; x=1788556738; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=gA9GfUae5e4kgX3+MPsZI52uWLZIn2pikfPs8urTqf0=;
        b=g2xUXjQtLDOkvTvuNvD2Nh8q69iHXHRHUzC+WWjS7zjfu9HgMcToWR72hounoPWULl
         b4W+/ZehcHwD6EEszbY1e5yqR0JDRCLqBbwjiKr8EKA0ASHnUKyHv6GD1Xb5SWlRil64
         uWwyj+7oQiUklCurPXW9vCSE4HiwJhOQjNKRs=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787951938; x=1788556738;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=gA9GfUae5e4kgX3+MPsZI52uWLZIn2pikfPs8urTqf0=;
        b=aTDTuJgo4aLO1q2zIPD+bnAircCpXairIXD5P0/vL1bDLhJWcegWBWeHzGpZIPt3r5
         RshP7KEJ21B8wJZ6jLwSNEsxAt/HkRbzUjAqyWdjQ2U1Vwz+/yIjx/SuP/SNB6p/j8YV
         RNkg9pU6tPvTtIPXprZiro4kIWjwtk7zsM9BGa+s0jDDDNt7q1+bE5VuZmub/PHYDM4c
         z2btAOn9ad/h18Le4rEjjJAiiQxXat6o7Qcf86tGbY96FSLd1tafUwCTp9dP9KWElVgV
         8a1OSZnPqsQs+2u39c7Jt3ilWmvdmLcELn9bnna5iOI18tkygLjG8AXciCQbq/nP1Fug
         kifQ==
X-Forwarded-Encrypted: i=1; AHgh+RqPgMN3fDa8AMbGa21+YagnVgzhlU7LaTUh2JAGVvpBV+ak9lSaU+i3eytQxp8Oa3Bqkrmz7uGJU2Q=@vger.kernel.org
X-Gm-Message-State: AFuF++mWsjeFesb7m/2tb+/Ls9cS+vdRY9hqp+5wTEGfBZ/Bw1aQxDms
	DfkuHpeva2F74G7rYz71VIG/9NB8b5ccSxTvldX1D7fL6wfjTHNdsZH81V9uZarOdkGwvs+OihR
	PS27MjyCiEh/SEWE=
X-Gm-Gg: AR+sD130L4JmB3dE1RhoyYaGvHx/fx7/g4NGM1qIya4Z9iZuT3PmksOn7CdYBM+TCb0
	lP62K2AkVIaTFTo940nE4bFMGHy7uE9Kdq4dU0vfFAPfJn87HzanTTJtqczh0gKve3nmUOlCXBd
	0aziXW4imdge2vmjhCtSrr5DpfHo9SC9IRicDmMpOrVft5QvY0n3pfKvb6/1cvCvxJtHWu0dYQV
	Fqj1TnUqjJdx9r+s2XwAk9ZzKDd8JV2W7xw4W1G34SIvKojAD6Lc6W3YS6TLS4vF+839r1w9XjG
	iQ0zevnmGoJ1z+CzRRRzyXyo3k0N9an33qKgCOBBQ3kEzm9ObYuzeVE+GQk91aF7gYwhlC+Ck9C
	HukkSs7pM26QX7x+/WxRGahTUmfMK1jq/4ey9wsXMi2Sl+0q21pYFjfzbEf8iWHQ6dS/OCeoWCD
	r3xI8CahgmRtRT6PjrbicoMFBOzc1sQC9O7Tpdrd2dA1dvSVH8viGwwtaM22kagtFw9nWPuDb/L
	XTSnuHSCarSWV+1b1ta5DdQ2JoNpG35vp2IpmIaQ/a+mI6EP7CaEZ4Iwg6e4c7sQWhEvtiwkdJT
	sGfM8G+JSw==
X-Received: by 2002:a05:6830:4429:b0:7eb:d848:c867 with SMTP id 46e09a7af769-7f4f22afeb6mr11087434a34.6.1787951937832;
        Fri, 28 Aug 2026 14:18:57 -0700 (PDT)
Received: from bill-the-cat (fixed-189-203-100-56.totalplay.net. [189.203.100.56])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f4fa9d6406sm2120226a34.27.2026.08.28.14.18.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 28 Aug 2026 14:18:57 -0700 (PDT)
Date: Fri, 28 Aug 2026 15:18:55 -0600
From: Tom Rini <trini@konsulko.com>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	=?iso-8859-1?Q?J=F6rg?= Sommer <joerg@jo-so.de>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
Message-ID: <20260828211855.GL3959812@bill-the-cat>
References: <20251210002850.318350-1-cel@kernel.org>
 <20251210002850.318350-3-cel@kernel.org>
 <apE90ZRZB8IW_AiS@jo-so.de>
 <178791679053.3510150.70411349578293852@noble.neil.brown.name>
 <91e02ca3-e985-47fa-aed8-0b50a5d7a3c9@app.fastmail.com>
 <20260828205116.GA266670@bill-the-cat>
 <a9a48faa-2663-40d7-86c8-ec2eaa967cdf@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a9a48faa-2663-40d7-86c8-ec2eaa967cdf@app.fastmail.com>
X-Clacks-Overhead: GNU Terry Pratchett

On Fri, Aug 28, 2026 at 05:06:14PM -0400, Chuck Lever wrote:
> 
> 
> On Fri, Aug 28, 2026, at 4:51 PM, Tom Rini wrote:
> > On Fri, Aug 28, 2026 at 09:27:41AM -0400, Chuck Lever wrote:
> >> 
> >> 
> >> On Fri, Aug 28, 2026, at 7:33 AM, NeilBrown wrote:
> >> > On Fri, 28 Aug 2026, Jörg Sommer wrote:
> >> >> Chuck Lever schrieb am Di 09. Dez, 19:28 (-0500):
> >> >> > From: Chuck Lever <chuck.lever@oracle.com>
> >> >> > 
> >> >> > A documenting comment in include/uapi/linux/nfs.h claims incorrectly
> >> >> > that NFSv2 defines NFSERR_INVAL. There is no such definition in either
> >> >> > RFC 1094 or https://pubs.opengroup.org/onlinepubs/9629799/chap7.htm
> >> >> > 
> >> >> > NFS3ERR_INVAL is introduced in RFC 1813.
> >> >> 
> >> >> Hello,
> >> >> 
> >> >> since this commit 0ac903d1bfdce8ff40657c2b7d996947b72b6645 was added, U-Boot
> >> >> 2022.04 (I don't know about newer versions) can no longer access symlinks in
> >> >> NFS shares. When I revert this commit, U-Boot can load the file behind the
> >> >> symlink. Real files are no problem.
> >> >> 
> >> >> The file I want to load is a symlink at the server:
> >> >> 
> >> >> ```
> >> >> % ls -l /srv/nfs/boot/Image.gz*
> >> >> lrwxrwxrwx 1 root root      41  7. Jul 16:29 /srv/nfs-con/boot/Image.gz -> Image.gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
> >> >> -rw-r--r-- 1 root root 5279373  7. Jul 16:29 /srv/nfs-con/boot/Image.gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
> >> >> ```
> >> >> 
> >> >> Without this commit:
> >> >> 
> >> >> ```
> >> >> u-boot=> nfs 0x42000000 /srv/nfs/boot/Image.gz
> >> >> Filename '/srv/nfs-con/boot/Image.gz'.
> >> >> Load address: 0x42000000
> >> >> Loading: #################################################################
> >> >> done
> >> >> Bytes transferred = 5279373 (508e8d hex)
> >> >> ```
> >> >> 
> >> >> But with this commit:
> >> >> 
> >> >> ```
> >> >> u-boot=> nfs 0x42000000 /srv/nfs/boot/Image.gz
> >> >> Filename '/srv/nfs-con/boot/Image.gz'.
> >> >> Load address: 0x42000000
> >> >> Loading:
> >> >> done
> >> >> ```
> >> >> 
> >> >> This is the network traffic:
> >> >> 
> >> >> ```
> >> >> No.	Time	Protocol	Length	Info
> >> >> 3	0.000370	Portmap	98	V2 GETPORT Call (Reply In 4) MOUNT(100005) V:1 UDP
> >> >> 4	0.000607	Portmap	70	V2 GETPORT Reply (Call In 3) Port:60340
> >> >> 5	0.000949	Portmap	98	V2 GETPORT Call (Reply In 6) NFS(100003) V:2 UDP
> >> >> 6	0.001046	Portmap	70	V2 GETPORT Reply (Call In 5) Port:2049
> >> >> 7	0.001368	MOUNT	126	V2 MNT Call (Reply In 8) /srv/nfs-con/boot
> >> >> 8	0.008026	MOUNT	102	V2 MNT Reply (Call In 7)
> >> >> 9	0.008389	NFS	146	V2 LOOKUP Call (Reply In 10), DH: 0x8c279135/Image.gz
> >> >> 10	0.008754	NFS	170	V2 LOOKUP Reply (Call In 9), FH: 0xcdddf154
> >> >> 11	0.009095	NFS	146	V2 READ Call (Reply In 12), FH: 0xcdddf154 Offset: 0 Count: 1024 TotalCount: 0
> >> >> 12	0.009189	NFS	70	V2 READ Reply (Call In 11) Error: NFS2ERR_IO
> >> >> 13	0.009511	MOUNT	102	V2 UMNTALL Call (Reply In 14)
> >> >> 14	0.010301	MOUNT	66	V2 UMNTALL Reply (Call In 13)
> >> >> ```
> >> >> 
> >> >> From packet 11 V2 READ Call
> >> >> 
> >> >> ```
> >> >> Remote Procedure Call, Type:Call XID:0x000050e1
> >> >>     XID: 0x000050e1 (20705)
> >> >>     Message Type: Call (0)
> >> >>     RPC Version: 2
> >> >>     Program: NFS (100003)
> >> >>     Program Version: 2
> >> >>     Procedure: READ (6)
> >> >>     [The reply to this request is in frame 12]
> >> >>     Credentials
> >> >>         Flavor: AUTH_UNIX (1)
> >> >>         Length: 20
> >> >>         Stamp: 0x00000000
> >> >>         Machine Name: <EMPTY>
> >> >>         UID: 0
> >> >>         GID: 0
> >> >>         Auxiliary GIDs (0)
> >> >>     Verifier
> >> >>         Flavor: AUTH_NULL (0)
> >> >>         Length: 0
> >> >> Network File System, READ Call FH: 0xcdddf154 Offset: 0 Count: 1024 TotalCount: 0
> >> >>     [Program Version: 2]
> >> >>     [V2 Procedure: READ (6)]
> >> >>     file
> >> >>         [hash (CRC-32): 0xcdddf154]
> >> >>         FileHandle: 010004010100540020bb3809040054002f2edde4000000000000000000000000
> >> >>     Offset: 0
> >> >>     Count: 1024
> >> >>     Total Count: 0
> >> >> ```
> >> >> 
> >> >> From packet 12 V2 READ Reply
> >> >> 
> >> >> ```
> >> >> Remote Procedure Call, Type:Reply XID:0x000050e1
> >> >>     XID: 0x000050e1 (20705)
> >> >>     Message Type: Reply (1)
> >> >>     [Program: NFS (100003)]
> >> >>     [Program Version: 2]
> >> >>     [Procedure: READ (6)]
> >> >>     Reply State: accepted (0)
> >> >>     [This is a reply to a request in frame 11]
> >> >>     [Time from request: 94.000 microseconds]
> >> >>     Verifier
> >> >>         Flavor: AUTH_NULL (0)
> >> >>         Length: 0
> >> >>     Accept State: RPC executed successfully (0)
> >> >> Network File System, READ Reply  Error: NFS2ERR_IO
> >> >>     [Program Version: 2]
> >> >>     [V2 Procedure: READ (6)]
> >> >>     Status: NFS2ERR_IO (5)
> >> >> ```
> >> >> 
> >> >> 
> >> >> I can locally revert this commit in our kernel, but is there any other way
> >> >> to get it working again?
> >> >
> >> > This is unfortunate.
> >> > U-boot has
> >> >
> >> > 		} else if ((rlen == -NFSERR_ISDIR) || (rlen == -NFSERR_INVAL)) {
> >> > 			/* symbolic link */
> >> > 			nfs_state = STATE_READLINK_REQ;
> >> > 			nfs_send();
> >> >
> >> > so we either need nfsdv2 to return NFSERR_ISDIR (for something that
> >> > isn't a directory) or NFSERR_INVAL (which is not a valid v2 error code),
> >> > or change u-boot to also check for NFSERR_IO (which is 5).
> >> 
> >> U-Boot's NFSERR_ISDIR check (quoted above) is the Sun-compatible
> >> path. The NFSERR_INVAL arm was presumably added for Linux NFSD?
> >> 
> >> So the pre-0ac903d1bfdc code is not something I want to go back to.
> >> Returning NFSERR_INVAL is incompatible with the reference NFSv2
> >> implementation, and so is NFSERR_IO.
> >> 
> >> Mapping nfserr_symlink to NFSERR_ISDIR affects the READ, WRITE, and
> >> SETATTR procedures. The Solaris NFS server returns NFSERR_ISDIR for
> >> READ and WRITE of a non-REG object, which suggests to me that is
> >> the behavior clients will expect.
> >> 
> >> IMO we should leave nfserr_wrong_type alone until we have a specific
> >> real-world complaint to address.
> >
> > On the U-Boot side of things, the code in question dates back to when
> > NFS support was originally added in 2004. The history here says that
> > someone added the symlink support on top of what was borrowed from
> > NetBSD, so yes, we're likely the originator of the incorrect behavior.
> > But also, this means that everything U-Boot that's ever been using this
> > feature now fails. And given the lag between the kernel change and the
> > bug report, it's not something that's in rapidly changing areas and
> > probably also in deployments that can't be updated. So perhaps things do
> > need to go back to the way it was.
> 
> That argument doesn't make sense to me, and moves NFSD backwards
> instead of forward.

I don't quite follow. The series here talks about correctness changes
that were found by comparison with the relevant documentation and not
about behavior with production / deployed systems. And it's not about
something new, it's about v2 support. On the U-Boot side I was ready to
drop it, except it turns out there's people still actively using it
today.

But also, doesn't this fall under the "you can't break ABI" side of
things? Especially since people have been using it for decades and
there's (seemingly) not some sort of security implication to the fix
(and we're talking about NFSv2, so...).

> Reverting the commit is fine for stable kernels, but getting the
> revert into mainline will take just as long as fixing it correctly.

I disagree about the speed of fixing it (being U-Boot) correctly. I have
a fix from Jörg today, and it could be in our October release, yes. When
will that actually be seen by people using U-Boot? Well, maybe newer
products based on... Fedora will pick up v2027.04, some semis will base
on v2027.01, but most places? Probably never.

> The "deployments can't be updated" also doesn't make sense: if
> they can't be updated, they won't be able to get the revert
> either.

By deployments I mean U-Boot deployments. It's notoriously hard to
update firmwares most of the time. Some testing labs refuse to because
of the value in testing the firmware most people likely have deployed
rather than the latest and greatest. So most of the time, it's never
updated. Can newer systems take advantage of good and specification
following update mechanisms? Sure. In practice? Only maybe.

-- 
Tom
