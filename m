Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out3.smtp.messagingengine.com ([66.111.4.27]:59990 "EHLO
	out3.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752310Ab1H3WH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2011 18:07:26 -0400
Message-ID: <4E5D5F1C.3020502@fastmail.fm>
Date: Wed, 31 Aug 2011 00:07:24 +0200
From: Bernd Schubert <bernd.schubert@fastmail.fm>
To: Andreas Dilger <adilger@whamcloud.com>
CC: "Ted Ts'o" <tytso@mit.edu>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        bfields@fieldses.org, hch@infradead.org, yong.fan@whamcloud.com,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3 2/4] Return 32/64-bit dir name hash according to usage
 type
References: <20110816115404.1810393.47239.stgit@localhost.localdomain> <20110816115414.1810393.92169.stgit@localhost.localdomain> <20110819222951.GC3578@thunk.org> <8B32DE36-9AD0-4418-86D8-4E453AA910DB@whamcloud.com>
In-Reply-To: <8B32DE36-9AD0-4418-86D8-4E453AA910DB@whamcloud.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/20/2011 08:23 AM, Andreas Dilger wrote:
> On 2011-08-19, at 4:29 PM, Ted Ts'o wrote:
>> On Tue, Aug 16, 2011 at 01:54:14PM +0200, Bernd Schubert wrote:
>>> +static inline int is_32bit_api(void)
>>> +{
>>> +#ifdef HAVE_IS_COMPAT_TASK
>>> +	return is_compat_task();
>>> +#else
>>> +	return (BITS_PER_LONG == 32);
>>> +#endif
>>
>> I assume is_compat_task() is coming from another patch?  What is the
>> status of that change?
>
> No, is_compat_task() is upstream for most (all?) of the architectures
> that support hybrid 32-/64-bit operation.  It is set at 32-bit syscall
> entry when running on 64-bit architectures.
>
> The only minor error in this patch (fixed with a new version from Bernd)
> is that this should be under CONFIG_COMPAT instead of HAVE_IS_COMPAT_TASK.

Yes sorry again about this. Could you please see patch series v4 please?

>
>> In the case where is_compat_task() is not defined, we can't just test
>> based on BITS_PER_LONG == 32, since even on an x86_64 machine, it's
>> possible we're running a 32-bit binary in compat mode....
>
> It is definitely available on x86_64.

Yep, otherwise it even wouldn't compile, at least not with patch series v4.


Thanks,
Bernd
