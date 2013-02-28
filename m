Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.cdf.utoronto.ca ([128.100.31.106]:36637 "HELO
	smtp.cdf.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754342Ab3B1QYN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Feb 2013 11:24:13 -0500
Message-ID: <512F84AC.1020705@cdf.toronto.edu>
Date: Thu, 28 Feb 2013 11:24:12 -0500
From: Iordan Iordanov <iordan@cdf.toronto.edu>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS v3 hangs with kernel version v3.2.0, 32-bit
References: <511BFB74.3060803@cdf.toronto.edu> <51253F36.40501@cdf.toronto.edu> <20130222150158.GB20588@fieldses.org>
In-Reply-To: <20130222150158.GB20588@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

On 02/22/13 10:01, J. Bruce Fields wrote:
> Some of that debugging is extremely verbose, yes.
>
> Since this list is for upstream (not ubuntu) development, most useful
> would probably be if you could work out whether the problem is
> reproduceable on the latest upstream kernel.

Understandable.

We've been unable to pin down what triggers this bug, so we are unable 
to reproduce it synthetically. It only appears to happen on shared 
servers with lots of NFS traffic, and in all cases it happened with more 
than a month of uptime. Also, we are unable to put an upstream kernel on 
a production machine.

These two conditions will make it exceedingly unlikely that we would be 
able to work this out with an upstream kernel.

Even if we were able to reproduce this with an upstream kernel, if it 
takes such a long time to reproduce could that have aged the kernel 
we're testing enough to invalidate our testing results?

Cheers!
Iordan
