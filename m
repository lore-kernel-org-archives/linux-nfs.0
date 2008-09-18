From: Peter Staubach <staubach@redhat.com>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Thu, 18 Sep 2008 15:03:01 -0400
Message-ID: <48D2A5E5.1080100@redhat.com>
References: <688309.69831.qm@web32604.mail.mud.yahoo.com> <76bd70e30809181124t78c0d574gaed5702095c02921@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Peter zijlstra <a.p.zijlstra@chello.nl>
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46127 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754236AbYIRTHJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Sep 2008 15:07:09 -0400
In-Reply-To: <76bd70e30809181124t78c0d574gaed5702095c02921-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Thu, Sep 18, 2008 at 6:53 AM, Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org> wrote:
>   
>> ----- Original Message ----
>>
>>     
>>> From: Andrew Morton <akpm@linux-foundation.org>
>>> To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
>>> Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>; linux-nfs list <linux-nfs@vger.kernel.org>; linux-kernel@vger.kernel.org; Peter zijlstra <a.p.zijlstra@chello.nl>
>>> Sent: Thursday, September 18, 2008 10:47:33 AM
>>> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
>>>
>>> On Thu, 18 Sep 2008 01:38:57 -0700 (PDT) Martin Knoblauch
>>> wrote:
>>>
>>>       
>>>>> No.  mount(8) will pass unrecognised options straight down into the
>>>>> filesystem driver.
>>>>>
>>>>>           
>>>>  Has that always been the case, or is it a recent change? I have to support
>>>>         
>>> RHEL4 userland, which is not really new.
>>>
>>> It's been that way for ever and ever.  It's how all these guys:
>>>
>>> y:/usr/src/25> grep Opt_ fs/*/super.c|wc
>>>     781    2626   33703
>>>
>>> get handled.
>>>       
>>  while that seems to be not to complicated, I seem to have a problem passing the mount options to the kernel. They come down as mount data version "6". Apparently mount(8) or mount.nfs(8) are doing the parsing and send down the legacy data block. So, what is the minimum version of mount or mount.nfs that pass the options down unaltered?
>>     
>
> The mount command has passed a string of options to the kernel for
> particular file systems for a while, but the facility for the NFS
> client to parse a string of mount options in the kernel was added only
> recently -- at least 2.6.23 or 2.6.24 is required to support this.
> Before this, the mount command parsed these options.
>
> For RHEL 4, based on 2.6.9, you are stuck.  It uses a binary structure
> whose fields must match between the kernel and user space.  For RH
> enterprise kernels, the ABI cannot change in a given release, so RH
> wouldn't take a patch to change the data structure that mount uses.
> You would have to maintain such a change yourself, and build your own
> kernels and mount command after each RHEL 4 update is released.
>
> I agree that a mount option would allow more fine-grained control over
> readahead.  A system wide parameter controlling readahead has always
> been a weakness.  Readahead, as implemented in the VFS, has a
> *per-file descriptor* context, however, which operates automatically
> (and can be tuned at run-time by an application with [mf]advise(2).
>
> As a future feature, this might work in better combination with the
> per-mount bdi changes proposed by Peter to provide maximal flexibility
> without exposing yet another confusing knob that could help some
> workloads but hurt others.

And perhaps add some dynamic tuning capabilities to the NFS client
code to just make it do "the right thing".  This would be better
than any tunables and would help to serve in other situations, such
as high bandwidth/latency networks, overloaded servers who don't
need more read-ahead READ requests piled on, etc...

       ps
