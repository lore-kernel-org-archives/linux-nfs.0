Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C697215B964;
	Wed, 28 Feb 2024 15:06:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709132810; cv=none; b=tMTrs1Us9Mj2uGK/fzavAv3ouUqYjpKF6Yxwg2FQ1maARxs+qDQW5Ny3Loq3fdNQxEaZYZ0rcFYYpr0K+9/mWPoLe4K9mQZJvxg9APrTPxM6lQgdfBgRO1SLpgIpu4RksSFq7cqIBN2NHamZrl+79hSNVrogD+eLSn3BTp5EBNM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709132810; c=relaxed/simple;
	bh=WsjvWNf6Aq0b7i4/xtCSY0NyA+Bs7a056XDGZGm0Rmk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=KK5eApQIDod+DXozW4LsW8yBh13pb0JQbZ9XnrcYeGD5LBXwpUliT7CoYvn1x613glFayvrPRPc80SocEQUgaqxNHYRbW8JVmZpta6R+vd10oZ9tNXPPpqAIIKu+0V8wKbRvu+nKDILLdDV03ITBrx7JhuX5Z0DM+jIwxEAmVQc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aHIyM4IK; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aHIyM4IK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D030C433F1;
	Wed, 28 Feb 2024 15:06:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1709132810;
	bh=WsjvWNf6Aq0b7i4/xtCSY0NyA+Bs7a056XDGZGm0Rmk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=aHIyM4IKyUSEW3Bk0kaQm5X1CrllkjOhHypt6SLXkkElA42eZJzDAjYLJ8H19uk8N
	 hXrbNtDmm/VwNO/O73Jkumq24Ei95LTQnMjTLoOYGrQZn4ip9SdIguYG45CfuSO5tj
	 iC5rkeb4rk0HCZxJltZPWcsZ5N89InhdbLWsRseabfb3k5bpMuWbJOoahhKnp2z8+n
	 55aP3bcXILsX/LvrjdnCm7PYNf/AJU/ZvuPMQpexXwyLsA2uIqDtZCYq4h83oZ2HbP
	 kpLC/4xO51GxltZAzE0SQx6BR5kMP3QpR9DWF4ESSy1VJY+5uzgSV/D3Adc6D5LVMS
	 0SgAL3eoY/69Q==
Date: Wed, 28 Feb 2024 15:06:46 +0000
From: Simon Horman <horms@kernel.org>
To: Chengming Zhou <chengming.zhou@linux.dev>
Cc: chuck.lever@oracle.com, jlayton@kernel.org, neilb@suse.de,
	kolga@netapp.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	Chengming Zhou <zhouchengming@bytedance.com>
Subject: Re: [PATCH v3] sunrpc: remove SLAB_MEM_SPREAD flag usage
Message-ID: <20240228150646.GJ292522@kernel.org>
References: <20240227171353.GE277116@kernel.org>
 <20240228031234.3512969-1-chengming.zhou@linux.dev>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20240228031234.3512969-1-chengming.zhou@linux.dev>

On Wed, Feb 28, 2024 at 03:12:34AM +0000, Chengming Zhou wrote:
> From: Chengming Zhou <zhouchengming@bytedance.com>
> 
> The SLAB_MEM_SPREAD flag used to be implemented in SLAB, which was
> removed as of v6.8-rc1, so it became a dead flag since the commit
> 16a1d968358a ("mm/slab: remove mm/slab.c and slab_def.h"). And the
> series[1] went on to mark it obsolete to avoid confusion for users.
> Here we can just remove all its users, which has no functional change.
> 
> [1] https://lore.kernel.org/all/20240223-slab-cleanup-flags-v2-1-02f1753e8303@suse.cz/
> 
> Signed-off-by: Chengming Zhou <zhouchengming@bytedance.com>
> ---
> v3:
>  - Improve the indentation, per Simon Horman.
> 
> v2:
>  - Update the patch description and include the related link to
>    make it clearer that SLAB_MEM_SPREAD flag is now a no-op.

Thanks for the updates.

Reviewed-by: Simon Horman <horms@kernel.org>

In future please consider the following:

1. Don't post new revisions of a series more than once every 24h
2. Do post new revisions as new email threads

Link: https://docs.kernel.org/process/maintainer-netdev.html



