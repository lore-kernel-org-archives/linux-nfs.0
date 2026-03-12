Received: from mail-qt1-f180.google.com (mail-qt1-f180.google.com [209.85.160.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B60BF3FBEBA
	for <linux-nfs@vger.kernel.org>; Thu, 12 Mar 2026 16:54:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773334496; cv=none; b=nGUvNE6qSXXg1jUKf1L747RurmbedKL1Lcn3BEA+l4LiuW+bVUUixny5nl4NYHMvRdQ5Jc+Xood9Ihm7+wkaMP7CkjEUzpZ+NPkpFFpcQ0cx+dP5cw29QPhD3AoUjjh9GaFIKpoLmvXkjwJWKLHMqkmlXTvRYfK1Zy1Vv9HxAdk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773334496; c=relaxed/simple;
	bh=ENv0+4bH9YdpFLGeURNwJ3+rEUsnNn74RNCtOl26SEA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=uLHOY4o8TOr6v3YH2Gjig3gQY4nCW4XYMmvwi+87RTw4alCEUdnSFodDaEFpzbpvjuLPqmzdhhErFEZ9wLRRS/wijUkUzYd9wJToS75N40Akx9uWwrqOE5Vz+uriMs56cmMlhZprSvyiUR13uHoxVEylpNpxk+z4FCwB/0VCwL8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca; spf=pass smtp.mailfrom=ziepe.ca; dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b=TCUycPJz; arc=none smtp.client-ip=209.85.160.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ziepe.ca
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="TCUycPJz"
Received: by mail-qt1-f180.google.com with SMTP id d75a77b69052e-509164dce91so11154691cf.1
        for <linux-nfs@vger.kernel.org>; Thu, 12 Mar 2026 09:54:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google; t=1773334491; x=1773939291; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
        bh=VQXCfPVu6b6dIVECzm0C8AUD7IL7VvpSkD5+M4S95sw=;
        b=TCUycPJzE2fI+UEqk7FktReSuNB+qmtoLxCPQIhObf2GoM3FGGUoUzmOL4EcJ8nqrV
         31wLWw0iuRrm5q/A3vl9oGJab4nkcB5GgE9L87TaBE5zWVhGKUEWMOYZrC4hQkz7+K+y
         MdSN9PZxg9+VlLOffdwRmQphGTW7UoGABbBRu3CtgROAhKqAusDMmmrNFgCXGsGgS+um
         4b3n9KF8H9mgZuxtPx/c84lVtPd3kX8R2XT1vLZ+RjANCZT5FGS44RpBGA5cN1JRJXTn
         oCOtB2FnqO56y3+c6Fos0prISIneHSMHrQ7vAs2p/teTVBOn2DfneDCxuRpkTU9D9cja
         6IGg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1773334491; x=1773939291;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=VQXCfPVu6b6dIVECzm0C8AUD7IL7VvpSkD5+M4S95sw=;
        b=kW1KoGfvNTKJY1P3IQW8I2MFh2sxKYs6MvZMPIeg8fZ2yHKGZZekCVFzi/DZNmatFB
         lZegOXtK+Eq4SgCmvjUg68lOTXyBI7/WehLAEvVOVmi8PRInf2VF31DCcazD9WolCK39
         k5ZVgZcHC9kOWTxRmwI8qpi5H/ryrza5jDhhtI69raxwJmJhJR+bOrGKN1M2g0/Q1X1w
         ri3Hy/s9bKDbqoVo4dQHGUONmpd4p2eKxvgHyoPXoxoHpWF3vWwpcaHzHn1RiwBTEUp4
         T40IK6KP3hhHBmmGeHRnu4f/9HVurN1ktmFkAMGx/cd+QOGYsLvAcyr9uqRLSTOWae+h
         XCYg==
X-Forwarded-Encrypted: i=1; AJvYcCUnAkmmuBZM/RPKv7pbE4NWA0tEdGlwn+hep4OMYKU4vP3uAutxgDxWk1HaAKml9iOKg/YT4LVqwu8=@vger.kernel.org
X-Gm-Message-State: AOJu0YxZ17s9i1em1wHac2ZxmcKJvAsn2Myhk6egFy2A4iBvWbV7BdJX
	SbE5G47bs1FplQymLWzB3hu/gu8PZYk/9UQ2cLp5bJMR2djTKXi41ihNnEIMqbqWLe4=
X-Gm-Gg: ATEYQzx7Ca+CUwCeo9yt6XfJOgQ9Ntiq9c5Fa3V1hoxdx2FSaALW1+lvQSkpcm7PvxE
	zUtpxGkEMX46IJVJQ4N1tF+vfPqA4PO+TnPQkHkPemFs7MMhJytuHvBFoHVUQi/KSCA03ZSGzXU
	bMr2SlCyR9wkUkAfpAaNQHFKXnh13SzzfzF8KWnoHl5qHTVN8VQkIIgOTutPIdkPeBEvsyN93Yu
	2OQv28s3jDrDvw2L1AWbd6Vb7BdY7p8Vrl116R/yIDc1y5gRCI9MVmY1ZEnr6K8tJys1VU/e6lZ
	GyR+uGXZfOT2ZG+lO4VNZuwD3a8SN/DMHYYXK0RyXNNN+h8LkBTflrpIn3t2WVgPT7dz5pjhIOF
	kvZb97+XMlU+V5IYbubSSvrGcRHLqNPvTwY2lWYZBm3AE5KjdAvudOy5HiHcPjYelQe3zS2iYgw
	3yaBzrstqsa+bBjmhgCB0TIHkPkQb0DRitwu+hfJoyPRzGfpO24LI2EsWaFv69HEyPPWZl33OF1
	uPA+SmFSq6k2vPypoI=
X-Received: by 2002:a05:622a:289:b0:509:44c3:5ffa with SMTP id d75a77b69052e-50957e10673mr1403911cf.52.1773334490530;
        Thu, 12 Mar 2026 09:54:50 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-142-162-112-119.dhcp-dynamic.fibreop.ns.bellaliant.net. [142.162.112.119])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-5093a119602sm36658181cf.28.2026.03.12.09.54.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 12 Mar 2026 09:54:49 -0700 (PDT)
Received: from jgg by wakko with local (Exim 4.97)
	(envelope-from <jgg@ziepe.ca>)
	id 1w0jJA-00000006i8N-40X9;
	Thu, 12 Mar 2026 13:54:48 -0300
Date: Thu, 12 Mar 2026 13:54:48 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Kuan-Wei Chiu <visitorckw@gmail.com>, Philipp Hahn <phahn-oss@avm.de>,
	amd-gfx@lists.freedesktop.org, apparmor@lists.ubuntu.com,
	bpf@vger.kernel.org, ceph-devel@vger.kernel.org, cocci@inria.fr,
	dm-devel@lists.linux.dev, dri-devel@lists.freedesktop.org,
	gfs2@lists.linux.dev, intel-gfx@lists.freedesktop.org,
	intel-wired-lan@lists.osuosl.org, iommu@lists.linux.dev,
	kvm@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	linux-btrfs@vger.kernel.org, linux-cifs@vger.kernel.org,
	linux-clk@vger.kernel.org, linux-erofs@lists.ozlabs.org,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-gpio@vger.kernel.org, linux-hyperv@vger.kernel.org,
	linux-input@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-leds@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mips@vger.kernel.org, linux-mm@kvack.org,
	linux-modules@vger.kernel.org, linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-phy@lists.infradead.org, linux-pm@vger.kernel.org,
	linux-rockchip@lists.infradead.org, linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-sctp@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-sound@vger.kernel.org,
	linux-stm32@st-md-mailman.stormreply.com,
	linux-trace-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	ntfs3@lists.linux.dev, samba-technical@lists.samba.org,
	sched-ext@lists.linux.dev, target-devel@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, v9fs@lists.linux.dev
Subject: Re: [PATCH 00/61] treewide: Use IS_ERR_OR_NULL over manual NULL
 check - refactor
Message-ID: <20260312165448.GN1469476@ziepe.ca>
References: <20260310-b4-is_err_or_null-v1-0-bd63b656022d@avm.de>
 <abBlpGKO842B3yl9@google.com>
 <20260312125730.GI1469476@ziepe.ca>
 <f5688b895eaebabae6545a0d9baf8f1404e8454e.camel@HansenPartnership.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f5688b895eaebabae6545a0d9baf8f1404e8454e.camel@HansenPartnership.com>

On Thu, Mar 12, 2026 at 11:32:37AM -0400, James Bottomley wrote:
> On Thu, 2026-03-12 at 09:57 -0300, Jason Gunthorpe wrote:
> > On Wed, Mar 11, 2026 at 02:40:36AM +0800, Kuan-Wei Chiu wrote:
> > 
> > > IMHO, the necessity of IS_ERR_OR_NULL() often highlights a
> > > confusing or flawed API design. It usually implies that the caller
> > > is unsure whether a failure results in an error pointer or a NULL
> > > pointer. 
> > 
> > +1
> > 
> > IS_ERR_OR_NULL() should always be looked on with suspicion. Very
> > little should be returning some tri-state 'ERR' 'NULL' 'SUCCESS'
> > pointer. What does the middle condition even mean? IS_ERR_OR_NULL()
> > implies ERR and NULL are semanticly the same, so fix the things to
> > always use ERR.
> 
> Not in any way supporting the original patch.  However, the pattern
> ERR, NULL, PTR is used extensively in the dentry code of filesystems. 
> See the try_lookup..() set of functions in fs/namei.c
> 
> The meaning is
> 
> PTR - I found it
> NULL - It definitely doesn't exist
> ERR - something went wrong during the lookup.
> 
> So I don't think you can blanket say this pattern is wrong.

Lots of places also would return ENOENT, I'd argue that is easier to
use..

But yes, I did use the word "suspicion" not blanket wrong :)

Jason
