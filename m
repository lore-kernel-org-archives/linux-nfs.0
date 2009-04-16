From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [pnfs] [RFC 0/4] nfs-utils: nfsd support for minor version
Date: Thu, 16 Apr 2009 15:01:47 -0400
Message-ID: <49E7809B.2020002@RedHat.com>
References: <49E2F6E4.2080501@panasas.com> <49E769C5.6010902@RedHat.com> <49E7721E.2070601@panasas.com> <49E7753C.4010300@RedHat.com> <20090416182313.GE450@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59840 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756772AbZDPTEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Apr 2009 15:04:47 -0400
In-Reply-To: <20090416182313.GE450@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> On Thu, Apr 16, 2009 at 02:13:16PM -0400, Steve Dickson wrote:
>> Benny Halevy wrote:
>>>> Benny Halevy wrote:
>>>>> Steve, please review the following patch that add support
>>>>> for controlling the nfsv4 minor version support via
>>>>> /proc/fs/nfsd/versions.
>>>>>
>>>>> [PATCH 1/4] utils/nfsd: fix -N optarg error printout
>>>>> 	This patch fixes an existing bug.
>>>> This is a bug... and has been committed...
>>>>
>>>>> [RFC 2/4] utils/nfsd: add support for minorvers4
>>>>> 	Under-the-cover support for minorvers4
>>>> I see you let minorvers4 default to zero, which means 4.1
>>>> support is off by default. Why? As long as we have away to
>>>> turn of 4.1 processing (i.e. your 4/4 patch), then I see
>>>> no reason we should have the support enabled by default. 
> 
> Was there a typo there?  You ask why 4.1 support is off, then say you
> see "no reason we should have the support enabled by default."  Those
> two statements seem to agree?  Did you mean "no reason we should
> not..."?
Yes... there was a typeo...  I meant to say I see no reason we 
should *not* have the v4.1 support enabled by default...

note to self... don't send email while in meetings... :-(

> 
>>> I was also thinking about using the new nfs-utils with old kernels.
>>> Though, these should not puke on seeing [-+]4.1, they'll
>>> just interpret it as enabling/disabling v4.
>>> I'll test that...
>> I just did... Using the '-N 4.1' flag to rpc.nfsd on an older 
>> kernel simply turns off all v4 processing... which is fine, IMHO...
> 
> If you want v4 running, but don't trust v4.1 yet, and want to use a
> mixture of new and old kernels--what configuration will you use?
I guess you're making the assumption that the client is v4.1 aware 
and is enabled by default... In that case I would suggest running
a 2.6.30+ kernel and use the '-N 4.1' flag... In all other cases
I think doing nothing (i.e. not specifying any flags) would work.

I do get your point, but as we did with the initial v4 support, 
having the support on by default and then having away to turn it
off is the correct approach... IMHO... 

steved.


