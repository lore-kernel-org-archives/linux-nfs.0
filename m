Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:7973 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbZDVWl4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 18:41:56 -0400
In-Reply-To: <49EE25FB.9050503@gmail.com>
References: <alpine.DEB.2.00.0904211202590.10241@p34.internal.lan>
	 <49EE25FB.9050503@gmail.com>
Date: Wed, 22 Apr 2009 15:41:55 -0700
Message-ID: <4807377b0904221541j7e2c4c0bh50d76d494b3cb306@mail.gmail.com>
Subject: Re: 2.6.29.1: Pid: 2831, comm: nfsd Not tainted 2.6.29.1 #4
From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
To: Aioanei Rares <krnl.list@gmail.com>
Cc: Justin Piszcz <jpiszcz@lucidpixels.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Apr 21, 2009 at 1:00 PM, Aioanei Rares <krnl.list@gmail.com> wrote:
> Justin Piszcz wrote:
>> This has been happening with 2.6.28.(x) and now 2.6.29.(x), can anyone
>> suggest the possible root cause of this problem, re: the nfsd page
>> allocation
>> failures:

> Yes, it happened to me too on a Debian unstable machine with more than one
> kernel, starting with 2.6.28 until now. I have a feeling it's a
> Debian-specific problem rather than a kernel one.

you may both want to try
echo 16384 > /proc/sys/vm/min_free_kbytes

or some other value depending on your amount of ram.  This change will
increase the minimum amount of memory available for network memory
allocations, which are called from softirq context to refill the NIC's
receive buffers.
