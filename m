Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E85A5221DC;
	Tue, 13 Oct 2026 15:37:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791905860; cv=none; b=tRzHhWEzcjQv1KbMRwR3tRyTR7YigNPxj1tzAvb0hOvhqKYrZJa8EWjE3SbtCBpMX4bG+wIBx3Gf8UxxfgBNI3Lo3irIryd0+o5mnKID9pyrDMMLGKS1qwdYnmqcZlntTqSD2CjwoY3/UZfxf8QW7GVezwJkv/nAhM9TIktNhyE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791905860; c=relaxed/simple;
	bh=GOs16IgachpnfudF9fqxmzqJjnjS+/ivSCVgF1EBU2w=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=aewzo1fVOJE2UU1IHrHoChl5VRN6r+jbFVjmX6wRKhWvVYpmktAHkD9lPUhDsLVTNyhRRZhHtm2Ajek4aP2j5FosY/SNexxGGSu9d6UWPhWvKPk/7wGepCGAPwH89BBRUInqhYFu7qJlX9rZQlmcPGlHkqFMb9flHJZkbj3gas4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HUW1CULq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HUW1CULq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8D66B1F000FF;
	Tue, 13 Oct 2026 15:37:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791905858;
	bh=6KGntCJveSKgTB5Os53pE5ueO2Ap7EeMI1AvE0Iy3Ck=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=HUW1CULqV0z82N6MB40nIhnlWwes1QqSsgOyJi7hx4z2T3w0JeeSi7TkYME2Zbv5A
	 kKA4C38aPuJS8/aGtVOvJNJOOsYU2pQBf2x02MepwVIXLGfua7tAo1o5FLJ3ESea1o
	 FdZrIx/7OAMEpU+lpGKcLT2o9UwN/m2jFNCsXmB7WgYDA436c4Ws8pjKjkTan8JQ6e
	 Oy7H6g3cLL8/vsJXxxjfbL6zQ/BcFqe1W613iADPuVDtXyqUDK7+xOEJLJGKTd2H6M
	 0ufphI0hmu7o7/eThMgC57kTRNNOIgfTBXX4Asaqr5T4LXjPFkh8SauNsW4zrpFV+M
	 vDytBgEdb5wAQ==
Date: Tue, 13 Oct 2026 09:37:37 -0600
From: Keith Busch <kbusch@kernel.org>
To: Daejun Park <daejun7.park@samsung.com>
Cc: "hch@lst.de" <hch@lst.de>, "sagi@grimberg.me" <sagi@grimberg.me>,
	"kch@nvidia.com" <kch@nvidia.com>,
	"kanie@linux.alibaba.com" <kanie@linux.alibaba.com>,
	"linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/2] nvmet: fix Reservation Acquire preempt sent by the
 holder
Message-ID: <as5QQbY2qa8Qq5N1@kbusch-mbp>
References: <CGME20261002065931epcms2p1cb2c16f98cf3b05f8c859ad92b0ad465@epcms2p1>
 <20261002065931epcms2p1cb2c16f98cf3b05f8c859ad92b0ad465@epcms2p1>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261002065931epcms2p1cb2c16f98cf3b05f8c859ad92b0ad465@epcms2p1>

On Fri, Oct 02, 2026 at 03:59:31PM +0900, Daejun Park wrote:
> nvmet_pr_preempt() does not follow NVMe Base Specification 2.1, section
> 8.1.22.7 when a Reservation Acquire command with the Preempt or Preempt
> and Abort action is sent by the reservation holder and the reservation
> is not of an All Registrants type.
> 
> Patch 1 fixes a use-after-free read in the path that handles a preempt
> sent by the holder.  It does not depend on patch 2 and comes first so
> that it can be backported alone.
> 
> Patch 2: a holder that preempts with the key of another registrant gets
> a successful completion, but that registrant stays registered and the
> reservation type is changed to RTYPE.  The pNFS SCSI layout server
> fences clients with this command (RFC 9561 section 2.2.3), so on an
> nvmet namespace nfsd logs a client as fenced while the client can still
> write to the device.  The patch lists what changes for a host that
> holds the reservation.

Thanks, applied to nvme-7.4.
