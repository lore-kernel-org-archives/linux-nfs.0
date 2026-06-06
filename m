Received: from linux.microsoft.com (linux.microsoft.com [13.77.154.182])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id DC607279792;
	Sat,  6 Jun 2026 06:50:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.77.154.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780728636; cv=none; b=pt2goQqdwv0fjPwuq+FSLnhegUbeefZXbX2lxc2EYXyDjtcEOoLWDlsrsjbjF2K5zkgnBnTjnOmwGQRDtEzXV5HBGGcg7+/J1odONGY6F0rTRHIPr3BVMUlfWLmLjo1aVv9gbvpEGdSGpOv3+KNzkO5I4mSrNhx0ePZqiiA0xy4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780728636; c=relaxed/simple;
	bh=ASMxGY4gAKSv+Sd0n3ZxR7MzaocXG9g17duQbi24vfE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=huMcXgsP+8wGscazLKPP6kwBabOsFKMX52R+0hxPRMkHwyOoT0qsZSvh598lZ1tHvVht6yYI10G3r1ZDnJCByMQJjJsnFiKD+dpADK167hQ2izlFtgMpv926rHup3htPjkDThO3UQNjY74UMiaIZfDdaws7HsWm6PZcOpvjI74A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com; spf=pass smtp.mailfrom=linux.microsoft.com; dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b=KEzT5ARs; arc=none smtp.client-ip=13.77.154.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.microsoft.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.microsoft.com header.i=@linux.microsoft.com header.b="KEzT5ARs"
Received: by linux.microsoft.com (Postfix, from userid 1173)
	id 2E00E20B7168; Fri,  5 Jun 2026 23:50:20 -0700 (PDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 linux.microsoft.com 2E00E20B7168
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.microsoft.com;
	s=default; t=1780728620;
	bh=tH653NbSmWShhrqHO75KERtMHsrIkCDX+cA3uzofLOg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=KEzT5ARsTUjn6reKkrwdJaP7fkQibLP6EKL9DaShkDrim6pD7moeJVUPAXAFqlZiQ
	 OnfLBe62DFRgqYAS5Yd48xXb3yUZCG/vEiTDp6IzwMs+lyR4jmyZXx4wy/jztlHm0R
	 gddWF2Cgp+XOPCA6cSrjf9I2QsnfupBBairNheVA=
Date: Fri, 5 Jun 2026 23:50:20 -0700
From: Erni Sri Satya Vennela <ernis@linux.microsoft.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Bart Van Assche <bvanassche@acm.org>, mkalderon@marvell.com,
	Jason Gunthorpe <jgg@ziepe.ca>, Leon Romanovsky <leon@kernel.org>,
	zyjzyj2000@gmail.com, sagi@grimberg.me, mgurtovoy@nvidia.com,
	haris.iqbal@ionos.com, jinpu.wang@ionos.com, kbusch@kernel.org,
	Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>,
	kch@nvidia.com, smfrench@gmail.com, linkinjeon@kernel.org,
	metze@samba.org, tom@talpey.com, chuck.lever@oracle.com,
	jlayton@kernel.org, neil@brown.name, okorniev@redhat.com,
	Dai.Ngo@oracle.com, trondmy@kernel.org, anna@kernel.org,
	achender@kernel.org, davem@davemloft.net, edumazet@google.com,
	kuba@kernel.org, pabeni@redhat.com, horms@kernel.org,
	kees@kernel.org, ebadger@purestorage.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, Jason Gunthorpe <jgg@nvidia.com>
Subject: Re: [PATCH rdma-next v6] RDMA: Change capability fields in
 ib_device_attr from int to u32
Message-ID: <aiPDLFM0xYlDYQFc@linuxonhyperv3.guj3yctzbm1etfxqx2vob5hsef.xx.internal.cloudapp.net>
References: <20260601092534.1764560-1-ernis@linux.microsoft.com>
 <5d3cac2b-4011-49c5-a142-55c85d38e90f@acm.org>
 <ah6gtquGDMvEXjcb@ashevche-desk.local>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ah6gtquGDMvEXjcb@ashevche-desk.local>

On Tue, Jun 02, 2026 at 12:21:58PM +0300, Andy Shevchenko wrote:
> On Mon, Jun 01, 2026 at 08:51:40AM -0700, Bart Van Assche wrote:
> > On 6/1/26 2:25 AM, Erni Sri Satya Vennela wrote:
> 
> ...
> 
> > > -	sdev->srq_size = min(srpt_srq_size, sdev->device->attrs.max_srq_wr);
> > > +	sdev->srq_size = min_t(u32, srpt_srq_size, sdev->device->attrs.max_srq_wr);
> > 
> > min_t() shouldn't be used if there is an alternative available. For the
> > SRP drivers, please make sure that both arguments of min() are unsigned
> > instead of using min_t().
> 
> Ah, I just answered in similar way against v5. I also mentioned clamp() there.

Yes. I'll be incorporating those changes in the next version.

- Vennela
> 
> -- 
> With Best Regards,
> Andy Shevchenko
> 
