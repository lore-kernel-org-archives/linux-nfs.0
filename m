From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] make capabilities support optional
Date: Fri, 23 Apr 2010 13:28:10 -0400
Message-ID: <4BD1D8AA.4030708@oracle.com>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <4BD1CADD.4050200@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>,
	Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63596 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755081Ab0DWRaa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Apr 2010 13:30:30 -0400
In-Reply-To: <4BD1CADD.4050200-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/23/2010 12:29 PM, Steve Dickson wrote:
> On 04/20/2010 04:46 AM, Mike Frysinger wrote:
>> The new code using libcap is quite minor, so rather than always reqiure
>> libcap support, make it a normal --enable type flag.  Current default
>> behavior is retained -- if libcap is found, it is enabled, else it is
>> disabled like every nfs-utils version in the past.
>>
>> Signed-off-by: Mike Frysinger<vapier@gentoo.org>
>>
> Committed...

I somehow missed this one.  Why are we disabling libcap?  And why are we 
adding another --enable flag when everyone has agreed that we should 
avoid that if at all possible?

It is especially on older systems that nfs-utils will break without 
libcap support.  Without CAP_NET_BIND, pmap_unregister() will fail when 
statd is shut down, leaving NSM registered with the portmapper, but with 
no active listeners.  When statd is started up again, it won't be able 
to register the new NSM listener ports.

That's the bug that was fixed by the addition of libcap.  I don't agree 
that is "quite minor."

-- 
chuck[dot]lever[at]oracle[dot]com
