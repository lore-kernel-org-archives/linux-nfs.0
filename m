Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932455AbbDMQcS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Apr 2015 12:32:18 -0400
Date: Mon, 13 Apr 2015 09:32:11 -0700
From: Zach Brown <zab@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org
Subject: Re: [PATCH RFC 1/3] vfs: add copy_file_range syscall and vfs helper
Message-ID: <20150413163211.GA8500@lenny.home.zabbo.net>
References: <1428703236-24735-1-git-send-email-zab@redhat.com>
 <1428703236-24735-2-git-send-email-zab@redhat.com>
 <CAHQdGtSwSf0j6ge7rCue48bZ08212Ny2Crz9WMadSno11N8z_g@mail.gmail.com>
 <20150411000208.GA20949@lenny.home.zabbo.net>
 <CAHQdGtSaaPHbvtBM3yVGtAFpEAP8ZquYvErknq_rCoCCK+W2bA@mail.gmail.com>
 <20150411090402.67d22d02@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150411090402.67d22d02@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > >> Could we perhaps instead of a length, define a 'pos_in_start' and a
> > >> 'pos_in_end' offset (with the latter being -1 for a full-file copy)
> > >> and then return an 'loff_t' value stating where the copy ended?
> > >
> > > Well, the resulting offset will be set if the caller provided it.  So
> > > they could already be getting the copied length from that.  But they
> > > might not specify the offsets.  Maybe they're just using the results to
> > > total up a completion indicator.
> > >
> > > Maybe we could make the length a pointer like the offsets that's set to
> > > the copied length on return.
> > 
> > That works, but why do we care so much about the difference between a
> > length and an offset as a return value?
> > 
> 
> I think it just comes down to potential confusion for users. What's
> more useful, the number of bytes actually copied, or the offset into the
> file where the copy ended?
> 
> I tend to the think an offset is more useful for someone trying to
> copy a file in chunks, particularly if the file is sparse. That gives
> them a clear place to continue the copy.
> 
> So, I think I agree with Trond that phrasing this interface in terms of
> file offsets seems like it might be more useful. That also neatly
> sidesteps the size_t limitations on 32-bit platforms.

Yeah, fair enough.  I'll rework it.

> > To be fair, the NFS copy offload also allows the copy to proceed out
> > of order, in which case the range of copied data could be
> > non-contiguous in the case of a failure. However neither the length
> > nor the offset case will give you the full story in that case. Any
> > return value can at best be considered to define an offset range whose
> > contents need to be checked for success/failure.
> > 
> 
> Yuck! How the heck do you clean up the mess if that happens? I guess
> you're just stuck redoing the copy with normal READ/WRITE?

I don't think anyone will worry about checking file contents.

Yes, technically you can get fragmented completion past the initial
contiguous region that the interface told you is done.   You can get
that with O_DIRECT today.

But it's a rare case that is not worth worrying about.  You'll retry at
the contiguous offset until it doesn't make progress and then fall back
to read/write.

- z
