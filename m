Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:21965 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318Ab0I2PHF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 11:07:05 -0400
Subject: Re: [PATCH 0/2] Two minor nfs-utils bug fixes
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CA1DAC9.4000004@RedHat.com>
Date: Wed, 29 Sep 2010 11:05:30 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <49542EDD-26A4-48E0-865D-BE7B3DE94FF3@oracle.com>
References: <20100920153714.2604.50581.stgit@ellison.1015granger.net> <4CA1DAC9.4000004@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 28, 2010, at 8:08 AM, Steve Dickson wrote:

> 
> 
> On 09/20/2010 11:39 AM, Chuck Lever wrote:
>> Hi Steve-
>> 
>> A couple of minor clean up patches.  I'm still working on the
>> "remount" issue.
>> 
>> ---
>> 
>> Chuck Lever (2):
>>      nfs-utils: Fix source code character encoding
>>      libnfs.a: Remove support/nfs/fstab.c
>> 
>> 
>> support/include/conffile.h |    2 
>> support/nfs/conffile.c     |    2 
>> support/nfs/fstab.c        |  554 --------------------------------------------
>> support/nfs/nfs_mntent.c   |    2 
>> support/nfs/xcommon.c      |    2 
>> utils/mount/fstab.c        |    2 
>> utils/mount/nfsmount.c     |    2 
>> 7 files changed, 6 insertions(+), 560 deletions(-)
>> delete mode 100644 support/nfs/fstab.c
>> 
> Committed...

It looks like the "Fix source code character encoding" commit is different than what I sent you. The accented "s" character in Arkadiusz' name has been changed to a latin "s" character in each instance.

Was that intentional?  If yes, then I will note that for future character encoding changes.

-- 
chuck[dot]lever[at]oracle[dot]com




