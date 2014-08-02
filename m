Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:58756 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbaHBDod (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Aug 2014 23:44:33 -0400
MIME-Version: 1.0
In-Reply-To: <20140802131946.207c597c@notabene.brown>
References: <53DA8443.407@candelatech.com>
	<20140801064217.01852788@notabene.brown>
	<53DAB307.2000206@candelatech.com>
	<20140801075053.2120cb33@notabene.brown>
	<20140801212120.1ae0eb02@tlielax.poochiereds.net>
	<CAABAsM7eh-Faaqmb9yf_xCVwi3cGpnTeOT8A4-e1jhwuEMPKWQ@mail.gmail.com>
	<20140802131946.207c597c@notabene.brown>
Date: Fri, 1 Aug 2014 23:44:32 -0400
Message-ID: <CAABAsM6dNYMus3GrrHiT82-kEb_hAftXnuhSx6SXeuq-E1+JLg@mail.gmail.com>
Subject: Re: Killing process in D state on mount to dead NFS server. (when
 process is in fsync)
From: Trond Myklebust <trondmy@gmail.com>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Ben Greear <greearb@candelatech.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 1, 2014 at 11:19 PM, NeilBrown <neilb@suse.de> wrote:
> On Fri, 1 Aug 2014 22:55:42 -0400 Trond Myklebust <trondmy@gmail.com> wrote:
>
>> > That still leaves some open questions though...
>> >
>> > Is that enough to fix it? You'd still have the dirty pages lingering
>> > around, right? Would a umount -f presumably work at that point?
>>
>> 'umount -f' will kill any outstanding RPC calls that are causing the
>> mount to hang, but doesn't do anything to change page states or NFS
>> file/lock states.
>
> Should it though?
>
>        MNT_FORCE (since Linux 2.1.116)
>               Force  unmount  even  if busy.  This can cause data loss.  (Only
>               for NFS mounts.)
>
> Given that data loss is explicitly permitted, I suspect it should.
>
> Can we make MNT_FORCE on NFS not only abort outstanding RPC calls, but
> fail all subsequent RPC calls?  That might make it really useful.   You
> wouldn't even need to "kill -9" then.

Yes, but if the umount fails due to other conditions (for example an
application happens to still have a file open on that volume) then
that could leave you with a persistent messy situation on your hands.

Cheers
  Trond
