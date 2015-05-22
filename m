Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34092 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756674AbbEVPCj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 May 2015 11:02:39 -0400
Message-ID: <555F4501.2090806@gmail.com>
Date: Fri, 22 May 2015 23:02:25 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 4/4] nfsd: Pin to vfsmnt instead of mntget
References: <554A149B.5060102@gmail.com>	<554A154B.6040103@gmail.com>	<20150508144031.6f0d3cda@notabene.brown>	<20150508134744.GA23753@fieldses.org>	<5550A9DF.1070908@gmail.com>	<20150513142515.6bd881c8@notabene.brown>	<20150515211134.GG29627@fieldses.org> <20150516092349.6718a946@notabene.brown>
In-Reply-To: <20150516092349.6718a946@notabene.brown>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/16/2015 7:23 AM, NeilBrown wrote:
> On Fri, 15 May 2015 17:11:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
>> On Wed, May 13, 2015 at 02:25:15PM +1000, NeilBrown wrote:
>>> On Mon, 11 May 2015 21:08:47 +0800 Kinglong Mee <kinglongmee@gmail.com> wrote:
>>>
>>>> On 5/8/2015 9:47 PM, J. Bruce Fields wrote:
>>>>> It could also be useful to have the ability to force an unmount even in
>>>>> the presence of locks.  That's not a safe default, but an
>>>>> "allow_force_unmount" export option might be useful.
>>>
>>> We already have a mechanism to forcibly drop any locks by writing some magic
>>> to /proc/fs/nfsd/unlock_{ip,filesystem}.  I don't think we need any more.
>>
>> Yeah, I remember thinking this sort of approach would have advantages,
>> maybe I was wrong, I need to revisit it.
>>
>> The unlock_{ip,filesystem} approach requires temporarily shutting down
>> mountd, doesn't it?
> 
> Not necessarily.
> It does require ensuring that new locks aren't suddenly taken though.
> 
> I imagine an early step in the migration process is to "ifconfig down" the
> virtual interface with the floating ID.  Then you can safely "unlock" and
> unmount any filesystems are that only accessed via the IP.
> 
> But you are right that using the "unlock_*" interface and then unmounting is
> racy in a way that we are trying to make "unmount" not racy.  So maybe an
> "allow_force_unmount" would have a place.

No, unlock_{ip,filesystem} are used for nlmlock, doesn't support nfsv4 resources.
Some other interfaces under /sys/kernel/debug/nfsd/forget_* support nfsv4 resources,
without for an filesystem. It seems will be removed sometime.

thanks,
Kinglong Mee
