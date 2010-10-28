From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/6] More fix-ups for nfs-utils-1.2.4
Date: Thu, 28 Oct 2010 11:39:22 -0400
Message-ID: <FEC1C1B9-A656-4C05-8111-74D4634384CD@oracle.com>
References: <20101026155216.19184.36979.stgit@matisse.1015granger.net> <4CC997A8.6060803@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:64505 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758467Ab0J1PkF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 11:40:05 -0400
In-Reply-To: <4CC997A8.6060803-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 28, 2010, at 11:32 AM, Steve Dickson wrote:

> Hey Chuck, 
> 
> I'm assuming this 6 patch series should replace (not merge with) 
> the 4 patch series you sent out earlier... 

Yes, it replaces them.  The 4 patch series was labelled "for review only," so I never intended that series to be merged.

> steved.
> 
> On 10/26/2010 11:57 AM, Chuck Lever wrote:
>> Hi Steve-
>> 
>> Here are rather more final versions of the patches I posted here last
>> week for review.  There are a couple of extra clean-ups here as well.
>> I think these are ready to be considered for nfs-utils 1.2.4.
>> 
>> ---
>> 
>> Chuck Lever (6):
>>      nfs(5): Document remount behavior
>>      nfs(5): Grammar and style fixes
>>      mount.nfs: mnt_freq and mnt_pass are always zero
>>      mount.nfs: Fix memory leak in nfs_sys_mount()
>>      mount: Fix compiler warning in nfs_parse_retry_option()
>>      nfs-utils: Remove all uses of AI_ADDRCONFIG
>> 
>> 
>> support/export/hostname.c     |    6 --
>> tests/nsm_client/nsm_client.c |    2 -
>> utils/mount/mount.c           |   34 +++++++------
>> utils/mount/network.c         |    3 -
>> utils/mount/nfs.man           |  107 ++++++++++++++++++++++++++++++++---------
>> utils/mount/stropts.c         |   20 ++++----
>> utils/statd/hostname.c        |    4 --
>> utils/statd/sm-notify.c       |    5 --
>> 8 files changed, 114 insertions(+), 67 deletions(-)
>> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




