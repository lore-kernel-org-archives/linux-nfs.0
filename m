Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754861Ab0LQO5H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 09:57:07 -0500
Message-ID: <4D0B7A3B.20403@RedHat.com>
Date: Fri, 17 Dec 2010 09:56:59 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Christoph Hellwig <hch@infradead.org>, Ric Wheeler <ricwheeler@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>	 <4D0A6503.7010901@RedHat.com> <20101216230524.GA16760@infradead.org>	 <4D0AA11A.2010307@gmail.com>  <20101216234058.GA17940@infradead.org> <1292556764.2895.41.camel@heimdal.trondhjem.org>
In-Reply-To: <1292556764.2895.41.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello

On 12/16/2010 10:32 PM, Trond Myklebust wrote:
> On Thu, 2010-12-16 at 18:40 -0500, Christoph Hellwig wrote:
>> On Thu, Dec 16, 2010 at 06:30:34PM -0500, Ric Wheeler wrote:
>>> This has nothing to do with shame or conspiracy, it has to do with
>>> doing changes in an orderly way so we can test and stabilize things
>>> in the upstream kernel.
>>>
>>> Changing both at once is not good for upstream or distros  in my opinion,
>>
>> Steve's mail reads pretty different from that.
>>
>> But it doesn't really matter as it doesn't make any sense - as Chuck
>> has explained theres zero overlap between the XDR decoder changes and
>> pnfs features anyway.  And if there was it's pretty clear something that
>> the about 98% of the userbase that's using NFSv3 uses should have more
>> priority over the 0.5% that are planning to maybe possibly use pnfs in
>> the next decade.
> 
> Hi guys,
> 
> I agree 100% with the basic premise that we should not have to deal with
> compatibility issues for NFSv4.1/pnfs backports when deciding what to
> merge upstream.
Cool...

> That said: as far as I can see, pretty much all these changes are
> confined to the NFSv2 and NFSv3 XDR code. I can quite understand why
> distros like Red Hat, SuSE, Debian, and others might want to avoid
> having to back port changes, given that the NFSv2 and NFSv3 code bases
> are supposed to be fully stable and frozen.
> 
> So my questions to Steve and Ric are:
> 
>      1. Specifically, which part of these changes are causing
>         backporting headaches for the RHEL-6 code base? Note that when
>         asking that question I am assuming that Red Hat will triage and
>         reject patches that conflict with their stability goals.
As of the 2.6.32 kernel we have been pulling in all the NFS (both 
client and server) changes from every major release. Meaning at 
this point the RHEL6.1 NFS code will be bug for bug compatible with 
the NFS code in the 2.6.37 mainline kernel. So no, we have not been 
reject many patches. 

The reason we have been pulling in the entire releases is because
when the pNFS bits are ready, we just want to pull them in and 
not have a backport from hell, basically forking from upstream.
Think of what has changed between the 2.6.32 and 2.6.37 kernels.
Backports like that are basically forks, IMHO... 

Keeping with this theory, when 2.6.38 is release we would pull
in the pNFS bits but also all the changes to parts of the code that
doesn't seem to be broken. 

The problem for us is RHEL6 has been released so the days of me 
pushing in hundreds and hundreds of patches that change parts 
of the code that, again, are not broken are gone. We simply do 
not have the resources to QA that amount of changes. 

Finally, history has shown, backporting large chucks of code out of 
a major release basically turns into a fork as well, which will 
not help us or more importantly not help this community.   


>      2. Could we set up some minimal set of patches that would allow the
>         pNFS backport while avoiding the need for a full backport of
>         Chuck's patches for NFSv2/v3? If so, what features do we need,
>         and what is not needed?
> 
> IOW: how can we refactor these patches so as to avoid tying the set of
> NFSv2/v3 changes to any pNFS interests?
I don't know... We could look into something like this, but from an 
upstream perspective, would it be worth it? Does it make sense? 
Again I don't know 

Trond, it will not be the end of the world if RHEL6 does not have
pNFS support... Again I think it would help the community by 
move the technology forward sooner verse later, but if it 
does not work out... so be it.. 

We will just move the support to RHEL 7 and move on... Heck that 
would make my life much easier (which I'm *always* a fan of ;-) ) 
and we always have Fedora... 

Its just when I heard, in this week's pNFS meeting, how close we were
of having some meaningful pNFS bits (i.e. wave2), we decided to make
this highly unusual (some call it shameful) request of asking to 
minimize changes until the pNFS bits stabilize... 

Thank you for even considering it... 

steved.

