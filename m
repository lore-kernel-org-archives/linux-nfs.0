Received: from mail-oi2-f1.google.com (mail-oi2-f1.google.com [74.125.231.193])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC85D3A9D95
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 20:51:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.193
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787950282; cv=none; b=bTsUVod6dKPfyBrXTpm68116wQCvA0sN3TxzldkYyoztarN5sJgABWqz/wXRbajCWV3Ra2jkahIzY8Rk5DGAMox/0Oz8simt+jDmG6BsXhQWDmW1FC67w64XbYDjPdqcInGja5504IP1cEUaKd47McEdJwSbUu/dr60wLUQBeDo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787950282; c=relaxed/simple;
	bh=2abQo4ptL16DZUIgaGoUCpeVmaYJBCs3tvDbsIhlKtc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ljD5GYhjazNUveEe/Pl3uX0jUFW/ZAIPkKaIxD01mlrvAXtahW7hdV90NVSq56TMVX38q5LhfCacQr+XTpTmITy6LoScHvGWcnizif9n1Eh5AFWCJ2ph40QuKDj0DYD/7/J3sheaiDPD+MyQ1nltMjYahY8Nz1aXdTi9a12Mn6o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=konsulko.com; spf=pass smtp.mailfrom=konsulko.com; dkim=pass (1024-bit key) header.d=konsulko.com header.i=@konsulko.com header.b=XCf2/tIY; arc=none smtp.client-ip=74.125.231.193
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=konsulko.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=konsulko.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=konsulko.com header.i=@konsulko.com header.b="XCf2/tIY"
Received: by mail-oi2-f1.google.com with SMTP id 46e09a7af769-7f4d7dee074so47414a34.0
        for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 13:51:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=konsulko.com; s=google; t=1787950280; x=1788555080; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=e/oA4tMZxnXZm6EPGfSCn1ehD9qrbTZjqAt/+4YJDQc=;
        b=XCf2/tIYYTaax11+9/xkgJQEhoEkO2O99Z65OJqutEUAIdQvEXD3iKdOF51KXbWvgG
         P4T1NVo1SDkcyUT8S+VGtZXWeFyEdm912u5v8JqWMcJMsqzn48xu9DW2hFalWaUXpsAo
         4g6Ni1rSAqQJVrrxbBlnqZDn6b1RxB02nXRPQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787950280; x=1788555080;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=e/oA4tMZxnXZm6EPGfSCn1ehD9qrbTZjqAt/+4YJDQc=;
        b=XLSvN4L5GrYkotPGS5bW4ZAqH2bT00hME20QH9XF0QnTmlQVq38WlzS/sDazh+VLox
         R2T8XDVrnII13ubh+zmHxRkhMTn7s6Fs+XbUeMnkDw+KIvffsBImY/HkkaXYdyT0kM/q
         Pil5hplSxwYk1zeQOt6W7Da9CzIjqSjgV9PXv751EjsJSi8JIr8OEV4lVhRjZZEXtlHX
         OWoSqEIPV/7fqmFGeSSzabSG5CRTBow5rYWnHofJeiQcQOSu044s4JH59K6SZBUBr+Wf
         Iiw9zCERUZYMaQQH77cagBb2L+UjhrpHn1xK8w8+hyW8zXYf1ipO+IRXSOc4oJHmfi1n
         QsLw==
X-Forwarded-Encrypted: i=1; AHgh+RoTIDKO/WY6wN9VI6qnJ1BpiMTHUQToZ/TaphwPzXGj8/mcTguB0PkhV/cNlbZaocI161RFPdzkIus=@vger.kernel.org
X-Gm-Message-State: AFuF++nfDVAxfETR5OdyN/BgyQWA42RDwyfgjuveG4fpI3uE1xogF0cf
	Yc62oFXVRHELczZwEyAwc9mvr75i5Z54m3BtpNqsAcMQ5FZiezXrJL90WIHH7LSFTcs=
X-Gm-Gg: AR+sD12Qd5dkxjfJH7pTHDC7qY9JiqpqBYpWOmMRNR6emcDctf6VTUctx0+/dGYJp9E
	Gv1sjZsyaFXvcyW4AsXpi8xulK/flJGr1zqF1G+RX0nX6ynlDaAy8UVGT6S09XGsNM/fGz+N6w9
	t56otdq9qTRA/PRfYMIzgfv0JDi3WjLUaBqWk3W7taP2y1M35LH7+L0iAz2/AedulSMp7vEsDjG
	qtj4hI7LGbUOYtAO0ZRlHP1ezV8LXgWz6vMwJDR06+cWgCxgUE8/zFuctGjrNDfGtlYjuvOF2Aj
	B33c9U5YGogkz/1ufEoJzCL+q46MfyUsXq1L1ezfC6eFybKwOVCKuvNoMmzCnO3o+R6ROqq4lAj
	L7SssKC+hgGRp6sJW7BhVdWLc238qk17gRmXMLIrvJ9Un1keZnKwlUuNi5qDsKZsAV4CMFtb6tR
	xHb+dZBsufbu//oiAHSSqn2CnWCFZQA6yS9zw+11VZagVeqYI1roO1IT9tY6mRWXEm21cTbPfjt
	ob1bmxnhYvh/hwohPCKABKykCF7RekwYaslm3RrCHA/MV84QSjtRzsk3HDRZV8DlozmyV421nUD
	IeLFQzWO2Q==
X-Received: by 2002:a05:6830:700b:b0:7dc:e78b:158 with SMTP id 46e09a7af769-7f6261857c0mr2640842a34.4.1787950279697;
        Fri, 28 Aug 2026 13:51:19 -0700 (PDT)
Received: from bill-the-cat (fixed-189-203-100-56.totalplay.net. [189.203.100.56])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f4fa99f86fsm2074115a34.22.2026.08.28.13.51.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 28 Aug 2026 13:51:19 -0700 (PDT)
Date: Fri, 28 Aug 2026 14:51:16 -0600
From: Tom Rini <trini@konsulko.com>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	=?iso-8859-1?Q?J=F6rg?= Sommer <joerg@jo-so.de>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
Message-ID: <20260828205116.GA266670@bill-the-cat>
References: <20251210002850.318350-1-cel@kernel.org>
 <20251210002850.318350-3-cel@kernel.org>
 <apE90ZRZB8IW_AiS@jo-so.de>
 <178791679053.3510150.70411349578293852@noble.neil.brown.name>
 <91e02ca3-e985-47fa-aed8-0b50a5d7a3c9@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <91e02ca3-e985-47fa-aed8-0b50a5d7a3c9@app.fastmail.com>
X-Clacks-Overhead: GNU Terry Pratchett

On Fri, Aug 28, 2026 at 09:27:41AM -0400, Chuck Lever wrote:
> 
> 
> On Fri, Aug 28, 2026, at 7:33 AM, NeilBrown wrote:
> > On Fri, 28 Aug 2026, Jörg Sommer wrote:
> >> Chuck Lever schrieb am Di 09. Dez, 19:28 (-0500):
> >> > From: Chuck Lever <chuck.lever@oracle.com>
> >> > 
> >> > A documenting comment in include/uapi/linux/nfs.h claims incorrectly
> >> > that NFSv2 defines NFSERR_INVAL. There is no such definition in either
> >> > RFC 1094 or https://pubs.opengroup.org/onlinepubs/9629799/chap7.htm
> >> > 
> >> > NFS3ERR_INVAL is introduced in RFC 1813.
> >> 
> >> Hello,
> >> 
> >> since this commit 0ac903d1bfdce8ff40657c2b7d996947b72b6645 was added, U-Boot
> >> 2022.04 (I don't know about newer versions) can no longer access symlinks in
> >> NFS shares. When I revert this commit, U-Boot can load the file behind the
> >> symlink. Real files are no problem.
> >> 
> >> The file I want to load is a symlink at the server:
> >> 
> >> ```
> >> % ls -l /srv/nfs/boot/Image.gz*
> >> lrwxrwxrwx 1 root root      41  7. Jul 16:29 /srv/nfs-con/boot/Image.gz -> Image.gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
> >> -rw-r--r-- 1 root root 5279373  7. Jul 16:29 /srv/nfs-con/boot/Image.gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
> >> ```
> >> 
> >> Without this commit:
> >> 
> >> ```
> >> u-boot=> nfs 0x42000000 /srv/nfs/boot/Image.gz
> >> Filename '/srv/nfs-con/boot/Image.gz'.
> >> Load address: 0x42000000
> >> Loading: #################################################################
> >> done
> >> Bytes transferred = 5279373 (508e8d hex)
> >> ```
> >> 
> >> But with this commit:
> >> 
> >> ```
> >> u-boot=> nfs 0x42000000 /srv/nfs/boot/Image.gz
> >> Filename '/srv/nfs-con/boot/Image.gz'.
> >> Load address: 0x42000000
> >> Loading:
> >> done
> >> ```
> >> 
> >> This is the network traffic:
> >> 
> >> ```
> >> No.	Time	Protocol	Length	Info
> >> 3	0.000370	Portmap	98	V2 GETPORT Call (Reply In 4) MOUNT(100005) V:1 UDP
> >> 4	0.000607	Portmap	70	V2 GETPORT Reply (Call In 3) Port:60340
> >> 5	0.000949	Portmap	98	V2 GETPORT Call (Reply In 6) NFS(100003) V:2 UDP
> >> 6	0.001046	Portmap	70	V2 GETPORT Reply (Call In 5) Port:2049
> >> 7	0.001368	MOUNT	126	V2 MNT Call (Reply In 8) /srv/nfs-con/boot
> >> 8	0.008026	MOUNT	102	V2 MNT Reply (Call In 7)
> >> 9	0.008389	NFS	146	V2 LOOKUP Call (Reply In 10), DH: 0x8c279135/Image.gz
> >> 10	0.008754	NFS	170	V2 LOOKUP Reply (Call In 9), FH: 0xcdddf154
> >> 11	0.009095	NFS	146	V2 READ Call (Reply In 12), FH: 0xcdddf154 Offset: 0 Count: 1024 TotalCount: 0
> >> 12	0.009189	NFS	70	V2 READ Reply (Call In 11) Error: NFS2ERR_IO
> >> 13	0.009511	MOUNT	102	V2 UMNTALL Call (Reply In 14)
> >> 14	0.010301	MOUNT	66	V2 UMNTALL Reply (Call In 13)
> >> ```
> >> 
> >> From packet 11 V2 READ Call
> >> 
> >> ```
> >> Remote Procedure Call, Type:Call XID:0x000050e1
> >>     XID: 0x000050e1 (20705)
> >>     Message Type: Call (0)
> >>     RPC Version: 2
> >>     Program: NFS (100003)
> >>     Program Version: 2
> >>     Procedure: READ (6)
> >>     [The reply to this request is in frame 12]
> >>     Credentials
> >>         Flavor: AUTH_UNIX (1)
> >>         Length: 20
> >>         Stamp: 0x00000000
> >>         Machine Name: <EMPTY>
> >>         UID: 0
> >>         GID: 0
> >>         Auxiliary GIDs (0)
> >>     Verifier
> >>         Flavor: AUTH_NULL (0)
> >>         Length: 0
> >> Network File System, READ Call FH: 0xcdddf154 Offset: 0 Count: 1024 TotalCount: 0
> >>     [Program Version: 2]
> >>     [V2 Procedure: READ (6)]
> >>     file
> >>         [hash (CRC-32): 0xcdddf154]
> >>         FileHandle: 010004010100540020bb3809040054002f2edde4000000000000000000000000
> >>     Offset: 0
> >>     Count: 1024
> >>     Total Count: 0
> >> ```
> >> 
> >> From packet 12 V2 READ Reply
> >> 
> >> ```
> >> Remote Procedure Call, Type:Reply XID:0x000050e1
> >>     XID: 0x000050e1 (20705)
> >>     Message Type: Reply (1)
> >>     [Program: NFS (100003)]
> >>     [Program Version: 2]
> >>     [Procedure: READ (6)]
> >>     Reply State: accepted (0)
> >>     [This is a reply to a request in frame 11]
> >>     [Time from request: 94.000 microseconds]
> >>     Verifier
> >>         Flavor: AUTH_NULL (0)
> >>         Length: 0
> >>     Accept State: RPC executed successfully (0)
> >> Network File System, READ Reply  Error: NFS2ERR_IO
> >>     [Program Version: 2]
> >>     [V2 Procedure: READ (6)]
> >>     Status: NFS2ERR_IO (5)
> >> ```
> >> 
> >> 
> >> I can locally revert this commit in our kernel, but is there any other way
> >> to get it working again?
> >
> > This is unfortunate.
> > U-boot has
> >
> > 		} else if ((rlen == -NFSERR_ISDIR) || (rlen == -NFSERR_INVAL)) {
> > 			/* symbolic link */
> > 			nfs_state = STATE_READLINK_REQ;
> > 			nfs_send();
> >
> > so we either need nfsdv2 to return NFSERR_ISDIR (for something that
> > isn't a directory) or NFSERR_INVAL (which is not a valid v2 error code),
> > or change u-boot to also check for NFSERR_IO (which is 5).
> 
> U-Boot's NFSERR_ISDIR check (quoted above) is the Sun-compatible
> path. The NFSERR_INVAL arm was presumably added for Linux NFSD?
> 
> So the pre-0ac903d1bfdc code is not something I want to go back to.
> Returning NFSERR_INVAL is incompatible with the reference NFSv2
> implementation, and so is NFSERR_IO.
> 
> Mapping nfserr_symlink to NFSERR_ISDIR affects the READ, WRITE, and
> SETATTR procedures. The Solaris NFS server returns NFSERR_ISDIR for
> READ and WRITE of a non-REG object, which suggests to me that is
> the behavior clients will expect.
> 
> IMO we should leave nfserr_wrong_type alone until we have a specific
> real-world complaint to address.

On the U-Boot side of things, the code in question dates back to when
NFS support was originally added in 2004. The history here says that
someone added the symlink support on top of what was borrowed from
NetBSD, so yes, we're likely the originator of the incorrect behavior.
But also, this means that everything U-Boot that's ever been using this
feature now fails. And given the lag between the kernel change and the
bug report, it's not something that's in rapidly changing areas and
probably also in deployments that can't be updated. So perhaps things do
need to go back to the way it was.

-- 
Tom
