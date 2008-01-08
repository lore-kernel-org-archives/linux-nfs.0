From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Man page update for timeo= and retrans= options.
Date: Tue, 8 Jan 2008 07:38:49 -0500
Message-ID: <8C656D7A-B20A-4583-9D56-07EECB4BFFEF@oracle.com>
References: <18301.39633.368089.130622@notabene.brown> <BA93E30A-817B-49B9-9703-FC77C2640BA5@oracle.com> <18306.53954.61368.902438@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:41014 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbYAHMlS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 07:41:18 -0500
In-Reply-To: <18306.53954.61368.902438-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

On Jan 7, 2008, at 8:32 PM, Neil Brown wrote:
> On Monday January 7, chuck.lever@oracle.com wrote:
>> Hi Neil-
>>
>> I just spent two months and rewrote all of nfs(5).  It should appear
>> in the next release of nfs-utils.  Steve, when can we expect to see
>> the updated man page?
>
> I thought I had seem some rewrite go past, but it wasn't in my inbox
> any more and also not it Steve's git so I just went ahead...

> I see it is in the .git now (as of Friday).

Good.  I hope others will also have a chance to look it over.  And  
thanks for your scrutiny, btw.

> Comments:
>  - It says UDP defaults to 7/10 of a second, but
>       nfs_init_timeout_values()
>    says:
> 		if (!to->to_initval)
> 			to->to_initval = 11 * HZ / 10;
>
>    which suggests 11/10 of a second.

Yup.  I forgot about that code change, which I believe was to make  
UDP on Linux work more like Solaris does.

>  - It says
>     If the retrans option is not specified, the NFS client retries
>     each request three times.
>
>   but nfs_init_timeout_values() says
>
> 	if (!to->to_retries)
> 		to->to_retries = 2;
>
>    which suggests it retries 2 time (or tries 3 times).

Yes, nfs(5) should be changed to say "tries each request 3 times."

>  - It says:
>       After each retransmission, the NFS client doubles the timeout
>       for that request, up to a maximum timeout length of 60 seconds.
>
>    but doesn't (to me) make it clear that only applies to UDP.

It follows "However, for NFS over UDP" .... But perhaps the UDP part  
can be wholly split into a separate paragraph to make the distinction  
more clear.

I'll post a patch with these updates to nfs(5).

>   For TCP, the timeouts appear to increase linearly up to 600 seconds.

The TCP RTT should not change after a timeout.  At least that was the  
way it worked when I modified it a few years ago.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
