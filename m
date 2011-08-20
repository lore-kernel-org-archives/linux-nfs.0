Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:61436 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab1HTGX2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Aug 2011 02:23:28 -0400
Subject: Re: [PATCH 3 2/4] Return 32/64-bit dir name hash according to usage type
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@whamcloud.com>
In-Reply-To: <20110819222951.GC3578@thunk.org>
Date: Sat, 20 Aug 2011 00:23:24 -0600
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        bfields@fieldses.org, bernd.schubert@fastmail.fm, hch@infradead.org,
        yong.fan@whamcloud.com, linux-fsdevel@vger.kernel.org
Message-Id: <8B32DE36-9AD0-4418-86D8-4E453AA910DB@whamcloud.com>
References: <20110816115404.1810393.47239.stgit@localhost.localdomain> <20110816115414.1810393.92169.stgit@localhost.localdomain> <20110819222951.GC3578@thunk.org>
To: "Ted Ts'o" <tytso@mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-08-19, at 4:29 PM, Ted Ts'o wrote:
> On Tue, Aug 16, 2011 at 01:54:14PM +0200, Bernd Schubert wrote:
>> +static inline int is_32bit_api(void)
>> +{
>> +#ifdef HAVE_IS_COMPAT_TASK
>> +	return is_compat_task();
>> +#else
>> +	return (BITS_PER_LONG == 32);
>> +#endif
> 
> I assume is_compat_task() is coming from another patch?  What is the
> status of that change?

No, is_compat_task() is upstream for most (all?) of the architectures
that support hybrid 32-/64-bit operation.  It is set at 32-bit syscall
entry when running on 64-bit architectures.

The only minor error in this patch (fixed with a new version from Bernd)
is that this should be under CONFIG_COMPAT instead of HAVE_IS_COMPAT_TASK.

> In the case where is_compat_task() is not defined, we can't just test
> based on BITS_PER_LONG == 32, since even on an x86_64 machine, it's
> possible we're running a 32-bit binary in compat mode....

It is definitely available on x86_64.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.



