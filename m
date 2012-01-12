Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:60634 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab2ALPJ2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 10:09:28 -0500
Received: by vcbfk14 with SMTP id fk14so1407503vcb.19
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2012 07:09:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326311086.26351.1.camel@lade.trondhjem.org>
References: <1326205835-2011-1-git-send-email-bergwolf@gmail.com>
 <20120110161406.GA8994@umich.edu> <CA+a=Yy4uaQmR7Zyi3HO5=tF2XbBsKaSgG90_SN2GUWAnTsZVUQ@mail.gmail.com>
 <1326311086.26351.1.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 12 Jan 2012 23:09:06 +0800
Message-ID: <CA+a=Yy7oTJzttctRMEFx=rOv7itV7tb2EpMp4uGq4UxkfqwW1w@mail.gmail.com>
Subject: Re: [PATCH RESEND 0/9] pnfsblock patches for 3.3 post-rc1
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jim Rees <rees@umich.edu>, linuxnfs <linux-nfs@vger.kernel.org>,
        mdw@umich.edu, honey@citi.umich.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 12, 2012 at 3:44 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2012-01-11 at 00:35 +0800, Peng Tao wrote:
>> On Wed, Jan 11, 2012 at 12:14 AM, Jim Rees <rees@umich.edu> wrote:
>> > Peng Tao wrote:
>> >
>> >  These are pnfsblock patches rebased on top of nfs-for-3.3. All patches
>> >  were sent to list before and merged by Benny.
>> >
>> > Once again, 8/9 and 9/9 failed to make it to the list.  Are these available
>> > via git?
>> sigh... vger seems always eating them... Thank you for pointing it out!
>>
>> Trond, please find 8/9 and 9/9 in attachments. 2/9 was lost before so
>> I also attached it here just in case. All patches are also available
>> at
>> git://github.com/bergwolf/linux.git for-trond-3.3
>> which is based on top of nfs-for-3.3
>>
>
> Please note that if you want patches to go into the stable stream, the
> email address is now
>
> Cc: stable@vger.kernel.org
>
> instead of the old stable@kernel.org.
>
Sorry, I just saw Greg's announcement.

I will update and resend the patches.

Thanks,
Tao
