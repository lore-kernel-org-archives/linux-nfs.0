From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 0/4] nfs-utils: nfsd support for minor version
Date: Thu, 16 Apr 2009 21:37:50 +0300
Message-ID: <49E77AFE.7000302@panasas.com>
References: <49E2F6E4.2080501@panasas.com> <49E769C5.6010902@RedHat.com> <49E7721E.2070601@panasas.com> <49E7753C.4010300@RedHat.com> <20090416182313.GE450@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:22950 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756220AbZDPSiO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2009 14:38:14 -0400
In-Reply-To: <20090416182313.GE450@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 16, 2009, 21:23 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
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

(that is what I assumed.)

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

It's a bit hackish, but I think that prepending 4.1 to 4 should
do the trick.

Writing "+2 +3 -4.1 +4" will allow you to disable
4.1 while enabling 4.0 on all kernels, old and new.

"+2 +3 +4.1 +4" would enable 4.0, and 4.1 on kernels
that support it.

Benny

> 
> --b.
