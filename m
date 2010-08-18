Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48348 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab0HROq6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 10:46:58 -0400
In-Reply-To: <20100818155359.66b9ddb6@notabene>
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	<87aaolwar8.fsf@basil.nowhere.org>
	<20100817174134.GA23176@fieldses.org>
	<20100817182920.GD18161@basil.fritz.box>
	<20100817190447.GA28049@fieldses.org>
	<AANLkTi=w1UA5ZZDBigpxMiL7A7DnbnQhLkg62JZpC6Ri@mail.gmail.com>
	<20100817203941.729830b7@lxorguk.ukuu.org.uk>
	<20100817192937.GD26609@fieldses.org>
	<20100818155359.66b9ddb6@notabene>
Date: Wed, 18 Aug 2010 07:46:57 -0700
Message-ID: <AANLkTim9qTjB15Hr+Te8UzgUpZWj41JMXLWf_gJrthc3@mail.gmail.com>
Subject: Re: Proposal: Use hi-res clock for file timestamps
From: "Patrick J. LoPresti" <lopresti@gmail.com>
To: Neil Brown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <andi@firstfloor.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 17, 2010 at 10:53 PM, Neil Brown <neilb@suse.de> wrote:
>
> I imagine something like this:
>  - Create a global struct timespec which is protected by a seqlock
>   Call it current_nfsd_time or similar.
>  - file_update_time reads this and uses it if it is newer than
>   current_fs_time.
>  - nfsd updates it whenever it reads an mtime out of an inode that matches
>   current_fs_time to the granularity of 1/HZ.

I think nfsd can simply update current_nfsd_time whenever the mtime it
reads from an inode is >= current_nfsd_time.  (The invariant you need
to maintain is that whenever nfsd reads an mtime, any timestamps
produced after that have a later time.  So just code it that way
directly.)

>   If the current value is before current_kernel_time, it
>   is set to current_kernel_time, otherwise tv_nsec is incremented -
>   unless that increases
>   beyond jiffies_to_usec(1)*1000 beyond current_kernel_time.
>  - the global 'struct timespec' is zeroed whenever system time is set
>   backwards.

I believe this works.

> [[You could probably make ext3 work reasonably well by adding a mount option
>  which:
>    - advertises s_time_gran as 1
>    - when storing: rounds timestamps up to the next second if tv_nsec != 0
>    - when loading, setting the timestamp to the current time if the stored
>      number matches current_kernel_time().tv_sec+1
>  You would get occasional forward jumps in mtime, but usually when you
>  aren't looking, and at least you would not get real changes that are not
>  reflected in mtime
> ]]

But I do not believe this works.

1) Modify file A
2) Modify file B
3) File A experiences one of those "occasional forward jumps in mtime"
(inode evicted + read back within 1 second)
4) mtimes on A and B are now out of order -- very bad

As Bruce mentioned, ext3 is a lost cause.

Regardless of any of this, however, the first step is to provide a
mount option to select the timestamp algorithm...  Because it is still
absurd that I cannot have accurate timestamps on my files here in the
21st century.

Once that is done, the rest is just providing the alternative
implementations and choosing defaults.

 - Pat
