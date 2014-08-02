Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:42464 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbaHBCzm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Aug 2014 22:55:42 -0400
MIME-Version: 1.0
In-Reply-To: <20140801212120.1ae0eb02@tlielax.poochiereds.net>
References: <53DA8443.407@candelatech.com>
	<20140801064217.01852788@notabene.brown>
	<53DAB307.2000206@candelatech.com>
	<20140801075053.2120cb33@notabene.brown>
	<20140801212120.1ae0eb02@tlielax.poochiereds.net>
Date: Fri, 1 Aug 2014 22:55:42 -0400
Message-ID: <CAABAsM7eh-Faaqmb9yf_xCVwi3cGpnTeOT8A4-e1jhwuEMPKWQ@mail.gmail.com>
Subject: Re: Killing process in D state on mount to dead NFS server. (when
 process is in fsync)
From: Trond Myklebust <trondmy@gmail.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: NeilBrown <neilb@suse.de>, Ben Greear <greearb@candelatech.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 1, 2014 at 9:21 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> On Fri, 1 Aug 2014 07:50:53 +1000
> NeilBrown <neilb@suse.de> wrote:
>
>> On Thu, 31 Jul 2014 14:20:07 -0700 Ben Greear <greearb@candelatech.com> wrote:
>>
>> > -----BEGIN PGP SIGNED MESSAGE-----
>> > Hash: SHA1
>> >
>> > On 07/31/2014 01:42 PM, NeilBrown wrote:
>> > > On Thu, 31 Jul 2014 11:00:35 -0700 Ben Greear <greearb@candelatech.com> wrote:
>> > >
>> > >> So, this has been asked all over the interweb for years and years, but the best answer I can find is to reboot the system or create a fake NFS server
>> > >> somewhere with the same IP as the gone-away NFS server.
>> > >>
>> > >> The problem is:
>> > >>
>> > >> I have some mounts to an NFS server that no longer exists (crashed/powered down).
>> > >>
>> > >> I have some processes stuck trying to write to files open on these mounts.
>> > >>
>> > >> I want to kill the process and unmount.
>> > >>
>> > >> umount -l will make the mount go a way, sort of.  But process is still hung. umount -f complains: umount2:  Device or resource busy umount.nfs: /mnt/foo:
>> > >> device is busy
>> > >>
>> > >> kill -9 does not work on process.
>> > >
>> > > Kill -1 should work (since about 2.6.25 or so).
>> >
>> > That is -[ONE], right?  Assuming so, it did not work for me.
>>
>> No, it was "-9" .... sorry, I really shouldn't be let out without my proof
>> reader.
>>
>> However the 'stack' is sufficient to see what is going on.
>>
>> The problem is that it is blocked inside the "VM" well away from NFS and
>> there is no way for NFS to say "give up and go home".
>>
>> I'd suggest that is a bug.   I cannot see any justification for fsync to not
>> be killable.
>> It wouldn't be too hard to create a patch to make it so.
>> It would be a little harder to examine all call paths and create a
>> convincing case that the patch was safe.
>> It might be herculean task to convince others that it was the right thing
>> to do.... so let's start with that one.
>>
>> Hi Linux-mm and fs-devel people.  What do people think of making "fsync" and
>> variants "KILLABLE" ??
>>
>> I probably only need a little bit of encouragement to write a patch....
>>
>> Thanks,
>> NeilBrown
>>
>
>
> It would be good to fix this in some fashion once and for all, and the
> wait_on_page_writeback wait is a major source of pain for a lot of
> people.
>
> So to summarize...
>
> The problem in a nutshell is that Ben has some cached writes to the
> NFS server, but the server has gone away (presumably forever). The
> question is -- how do we communicate to the kernel that that server
> isn't coming back and that those dirty pages should be invalidated so
> that we can umount the filesystem?
>
> Allowing fsync/close to be killable sounds reasonable to me as at least
> a partial solution. Both close(2) and fsync(2) are allowed to return
> EINTR according to the POSIX spec. Allowing a kill -9 there seems
> like it should be fine, and maybe we ought to even consider letting it
> be susceptible to lesser signals.
>
> That still leaves some open questions though...
>
> Is that enough to fix it? You'd still have the dirty pages lingering
> around, right? Would a umount -f presumably work at that point?

'umount -f' will kill any outstanding RPC calls that are causing the
mount to hang, but doesn't do anything to change page states or NFS
file/lock states.

Cheers
  Trond
