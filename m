Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:45640 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820Ab1HVXYv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2011 19:24:51 -0400
Message-ID: <4E52E538.7040807@panasas.com>
Date: Mon, 22 Aug 2011 16:24:40 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Peng Tao <bergwolf@gmail.com>
CC: <benny@tonian.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/3] recoalesce when ld read/write fails
References: <1313197213-1651-1-git-send-email-bergwolf@gmail.com> <4E4AD655.9090305@panasas.com> <CA+a=Yy6xNFu62nZavt1KnrZWTZGjgR3H=bgF-uERsf=xp7TARg@mail.gmail.com>
In-Reply-To: <CA+a=Yy6xNFu62nZavt1KnrZWTZGjgR3H=bgF-uERsf=xp7TARg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/17/2011 06:42 AM, Peng Tao wrote:
<snip>
>> They look *really* good these patches. But as you said, do they actually work?
>>
>> Did you test any of this? I mean do you have a facility to inject random
>> IO errors and test this out?
> I have tested the patchset by forcing all bio to fail so IO will be
> re-send to MDS. Also I tested read/write by forcing all IO that
> touches pages beyond 16K to fail. Both tests passed.
> 

So that sounds good. Why don't you like these patches?

>>
<snip>
> I tried to test "git clone linux" on a 384M memory VM but it hangs as
> server is rejecting layoutget with NFS4ERR_LAYOUTTRYLATER.
> /proc/self/mountstats shows that client has sent more than 14K
> layoutgets but never returns any layout. I checked related code and it
> seems client should send layoutreturn for closed files. Will git keep
> all files open? Or is there any case that client won't return the
> layout even after file close?
> 

Yes! our client will never ever return any layouts. The forgetful
model for you. It will only ever "layout_return" on evict_inode which
is way after close, when the Kernel decides to cleanup the inode
cache. Which only happens after a while.

If Your layout driver sets the RETURN_ON_CLOSE bit on the layout
then the pNFSD server code will simulate a layout_return on a file
close. This is what I use in EXOFS and it works very well. (I should
know because I wrote this patch for the pnfsd server)

It looks like your blocks-based pNFSD filesystem needs layouts
returned. Set the res->lg_return_on_close = true; flag in your
.layout_get member and you should see layout_return on close.

Look in Benny's pNFS tree at fs/exofs/export.c file how I do
it there.

> This seems to be another issue though.
> 

Yes this is a different Issue.

It looks from what you tested that the second approach works
well. I'll also test this out later on. Lets not rule these
out yet.

> Thanks,
> Tao

Sorry for the late response I just came back from Vacation,
It'll me some time to catch up

Thanks
Boaz
