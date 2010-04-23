From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] make capabilities support optional
Date: Fri, 23 Apr 2010 14:22:19 -0400
Message-ID: <4BD1E55B.2090703@RedHat.com>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <4BD1CADD.4050200@RedHat.com> <4BD1D8AA.4030708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752301Ab0DWSWq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Apr 2010 14:22:46 -0400
In-Reply-To: <4BD1D8AA.4030708@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/23/2010 01:28 PM, Chuck Lever wrote:
> On 04/23/2010 12:29 PM, Steve Dickson wrote:
>> On 04/20/2010 04:46 AM, Mike Frysinger wrote:
>>> The new code using libcap is quite minor, so rather than always reqiure
>>> libcap support, make it a normal --enable type flag.  Current default
>>> behavior is retained -- if libcap is found, it is enabled, else it is
>>> disabled like every nfs-utils version in the past.
>>>
>>> Signed-off-by: Mike Frysinger<vapier@gentoo.org>
>>>
>> Committed...
> 
> I somehow missed this one.  Why are we disabling libcap?  And why are we
> adding another --enable flag when everyone has agreed that we should
> avoid that if at all possible?
The justification I was used was it made nfs-utils more portable on 
systems/distros that may not have the libcap support. 

> 
> It is especially on older systems that nfs-utils will break without
> libcap support.  Without CAP_NET_BIND, pmap_unregister() will fail when
> statd is shut down, leaving NSM registered with the portmapper, but with
> no active listeners.  When statd is started up again, it won't be able
> to register the new NSM listener ports.
Hmm... I agree the unregister() would fail on exit, but that's the reason 
an unregister() (and then an register) is done on start up before the 
privileges are drop... Actually this how it worked for a very long time,
well before the capabilities support added... 

steved.
