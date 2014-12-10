Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51796 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756199AbaLJONU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 09:13:20 -0500
To: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH v2 0/5] rework access to /proc/net/rpc
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 10 Dec 2014 15:13:18 +0100
From: =?UTF-8?Q?David_H=C3=A4rdeman?= <david@hardeman.nu>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        =?UTF-8?Q?Timo_Ter=C3=A4s?= <timo.teras@gmail.com>
In-Reply-To: <20141210080929.13c1fa30@vostro>
References: <399e974867e03c052fedfa8e8fd688ca@hardeman.nu>
 <20141209104236.2204671c@vostro>
 <24f5038cdd74837afb8a53887eb4b803@hardeman.nu> <54871E87.7000300@RedHat.com>
 <20141209202652.GA32738@hardeman.nu> <54876A0C.3090109@RedHat.com>
 <20141210080929.13c1fa30@vostro>
Message-ID: <38d798fa4bd1434bbcc3c125509b2826@hardeman.nu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2014-12-10 07:09, Timo Teras wrote:
> On Tue, 09 Dec 2014 16:30:52 -0500
> Steve Dickson <SteveD@redhat.com> wrote:
>>>> My understanding these patches were needed to make nfs-utils
>>>> compatible with the musl c-library. That is the case, correct?
> 
> Yes. It is because musl FILE implementation uses writev() and readv()
> with multiple buffers, and the kernel side does not handle that.

I should probably note in that case that my patches to gssd include a 
call to fscanf, I'm guessing that'd be a problem for you?

> In my opinion the dynamic allocation is a step backward, rather then
> forwards. It adds potential failure (out of memory), is not required,
> and it does not add any features either.
> 
> IMHO, "just because it used to be so" is a bad excuse. And it would
> just cause additional code making harder to debug and easier to fail.
> Why add complexity when it can be done simpler?

I think PATH_MAX is a good counter-example.

But I think we can at least agree that we're discussing coding style 
now, which is a bit like discussing Emacs vs vi, and I doubt we'll ever 
reach an agreement... :)

Regards,
David
