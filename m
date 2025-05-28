Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 42DD7220F59;
	Wed, 28 May 2025 19:45:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1748461501; cv=none; b=C7uy85rfURqSREtzNZljs/apTw7sFganztKUJ/tJGr1xqamtn17hCqEoICGAlRRDLHq0tBz2DGlBHVYddqP1sCGq1t3txyntxHWRjjslX9B4Jd6Cc9vCDLJ4CM/hNTAcJ2XnEAYihy7teJempIWD3cAMph7He528ovDKjo1nzHk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1748461501; c=relaxed/simple;
	bh=BLmCk3jPE0EhM3g0EHTiGDkkAPm+VGJckSWZZUhnQWI=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=FMwScC8bMNJ874JWgC42K0wRllZPnz1RATFWdYRmNOnDfClv1PFKDmOeQLaNH+VjR77wkpMfSqYCdc/YhB4Pfxjs9EG8WOEYjJIpCeo2QOSze7hMY1UmHsBeY4F9DQ9BKmYcpHVxz0miaRzt0ifGQcJIWQgXfer0Ane3sDOcewc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SXtyFqwr; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SXtyFqwr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3C44DC4CEE3;
	Wed, 28 May 2025 19:45:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1748461500;
	bh=BLmCk3jPE0EhM3g0EHTiGDkkAPm+VGJckSWZZUhnQWI=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=SXtyFqwrZHSc8u0jBRMnnGYlqxS7OwT0Oo7DvKmkxOkU9B4U6bl41ia6khLj5uO+4
	 ElK4S7VuHvHB6Oyp3vwq2gjeDlE7tZpJfFQtNsRFg0QQKZTzuTzBxlD82soyRGveIt
	 YWgCPGlyHFdOx0MKkTOsO+w/JnSiv91RtBnpks8SbmGW/+vE04IVCUaih2qPzoI+8v
	 drgU1nsQNTpnH+Y1ezNlV793qivC2imFnffh99GbclvGYgV7gzytC9y+QBxc7zQY18
	 4tDxCSjq60zLgYOeuxacMCD3AZMP4fg7/wfcuMP+LYnKNNpyuD2AGizNhYbFC5pJX9
	 6opnIkACE8Y1A==
Message-ID: <f5ddb28b-996e-4cbc-ad8d-c0af1c800e28@kernel.org>
Date: Wed, 28 May 2025 15:44:59 -0400
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [GIT PULL] NFSD changes for v6.16
To: Linus Torvalds <torvalds@linux-foundation.org>,
 Konstantin Ryabitsev <konstantin@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
 Jeff Layton <jlayton@kernel.org>
References: <20250527141706.388993-1-cel@kernel.org>
 <CAHk-=wggC6PP9ZNwKY7sEzdsC7h8qySA7pjqAchrYowniADUQg@mail.gmail.com>
Content-Language: en-US
From: Chuck Lever <cel@kernel.org>
Organization: kernel.org
In-Reply-To: <CAHk-=wggC6PP9ZNwKY7sEzdsC7h8qySA7pjqAchrYowniADUQg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 5/28/25 3:38 PM, Linus Torvalds wrote:
> On Tue, 27 May 2025 at 07:17, <cel@kernel.org> wrote:
>>
>> NFSD 6.16 Release Notes
> 
> Pulled - but I have a silly request.
> 
> Can you fix your kernel.org email sending setup so that you have a
> real name, not just your login name?

Fixed, I think, in my ~/.gitconfig.


-- 
Chuck Lever
