Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:60292 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284Ab2JXEPm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 00:15:42 -0400
From: Nix <nix@esperi.org.uk>
To: Eric Sandeen <sandeen@redhat.com>
Cc: "Ted Ts'o" <tytso@mit.edu>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Bryan Schumaker <bjschuma@netapp.com>, Peng Tao <bergwolf@gmail.com>,
        Trond.Myklebust@netapp.com, gregkh@linuxfoundation.org,
        linux-nfs@vger.kernel.org
Subject: Re: Apparent serious progressive ext4 data corruption bug in 3.6.3 (and other stable branches?)
References: <87objupjlr.fsf@spindle.srvr.nix>
	<20121023013343.GB6370@fieldses.org> <87mwzdnuww.fsf@spindle.srvr.nix>
	<20121023143019.GA3040@fieldses.org>
	<874nllxi7e.fsf_-_@spindle.srvr.nix>
	<87pq48nbyz.fsf_-_@spindle.srvr.nix> <508740B2.2030401@redhat.com>
Date: Wed, 24 Oct 2012 05:15:10 +0100
In-Reply-To: <508740B2.2030401@redhat.com> (Eric Sandeen's message of "Tue, 23
	Oct 2012 20:13:22 -0500")
Message-ID: <87txtkld4h.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 24 Oct 2012, Eric Sandeen uttered the following:

> On 10/23/12 3:57 PM, Nix wrote:
>> The only unusual thing about the filesystems on this machine are that
>> they have hardware RAID-5 (using the Areca driver), so I'm mounting with
>> 'nobarrier': 
>
> I should have read more.  :(  More questions follow:
>
> * Does the Areca have a battery backed write cache?

Yes (though I'm not powering off, just rebooting). Battery at 100% and
happy, though the lack of power-off means it's not actually getting
used, since the cache is obviously mains-backed as well.

> * Are you crashing or rebooting cleanly?

Rebooting cleanly, everything umounted happily including /home and /var.

> * Do you see log recovery messages in the logs for this filesystem?

My memory says yes, but nothing seems to be logged when this happens
(though with my logs on the first filesystem damaged by this, this is
rather hard to tell, they're all quite full of NULs by now).

I'll double-reboot tomorrow via the faulty kernel and check, unless I
get asked not to in the interim. (And then double-reboot again to fsck
everything...)

>> the full set of options for all my ext4 filesystems are:
>> 
>> rw,nosuid,nodev,relatime,journal_checksum,journal_async_commit,nobarrier,quota,
>> usrquota,grpquota,commit=30,stripe=16,data=ordered,usrquota,grpquota
>
> ok journal_async_commit is off the reservation a bit; that's really not
> tested, and Jan had serious reservations about its safety.

OK, well, I've been 'testing' it for years :) No problems until now. (If
anything, I was more concerned about journal_checksum. I thought that
had actually been implicated in corruption before now...)

> * Can you reproduce this w/o journal_async_commit?

I can try!

-- 
NULL && (void)
