From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [RFC 0/4] nfs-utils: nfsd support for minor version
Date: Thu, 16 Apr 2009 20:59:58 +0300
Message-ID: <49E7721E.2070601@panasas.com>
References: <49E2F6E4.2080501@panasas.com> <49E769C5.6010902@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15140 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756368AbZDPSAW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2009 14:00:22 -0400
In-Reply-To: <49E769C5.6010902-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 16, 2009, 20:24 +0300, Steve Dickson <SteveD@redhat.com> wrote:
> Hey Benny,
> 
> Benny Halevy wrote:
>> Steve, please review the following patch that add support
>> for controlling the nfsv4 minor version support via
>> /proc/fs/nfsd/versions.
>>
>> [PATCH 1/4] utils/nfsd: fix -N optarg error printout
>> 	This patch fixes an existing bug.
> This is a bug... and has been committed...
> 
>> [RFC 2/4] utils/nfsd: add support for minorvers4
>> 	Under-the-cover support for minorvers4
> I see you let minorvers4 default to zero, which means 4.1
> support is off by default. Why? As long as we have away to
> turn of 4.1 processing (i.e. your 4/4 patch), then I see
> no reason we should have the support enabled by default. 

I was also thinking about using the new nfs-utils with old kernels.
Though, these should not puke on seeing [-+]4.1, they'll
just interpret it as enabling/disabling v4.
I'll test that...

> 
>> [RFC 3/4] utils/nfsd: add -n --nfs-version option
>> 	Add a command line option to enable versions
> I'm assuming you added this to be able to turn on 4.1 processing.
> But 4.1 is on by default, the '-n' flag not need, correct?

Right, and that would follow the existing design.

> 
>> [RFC 4/4] utils/nfsd: enable/disable minorvers4 via command line
>> 	Extend -n/-N syntax to accept <version>.<minorversion>
> look reasonable... 

Great.  Thanks for the review!

I think I'll have some time next week 
to revise and resend this patchset.

Benny

> 
> steved.
