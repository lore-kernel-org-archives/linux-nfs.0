Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54017 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754323AbaHAMri (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Aug 2014 08:47:38 -0400
Date: Fri, 1 Aug 2014 14:47:34 +0200
From: Jan Kara <jack@suse.cz>
To: NeilBrown <neilb@suse.de>
Cc: Ben Greear <greearb@candelatech.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: Killing process in D state on mount to dead NFS server. (when
 process is in fsync)
Message-ID: <20140801124734.GB5431@quack.suse.cz>
References: <53DA8443.407@candelatech.com>
 <20140801064217.01852788@notabene.brown>
 <53DAB307.2000206@candelatech.com>
 <20140801075053.2120cb33@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140801075053.2120cb33@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri 01-08-14 07:50:53, NeilBrown wrote:
> On Thu, 31 Jul 2014 14:20:07 -0700 Ben Greear <greearb@candelatech.com> wrote:
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
> > 
> > On 07/31/2014 01:42 PM, NeilBrown wrote:
> > > On Thu, 31 Jul 2014 11:00:35 -0700 Ben Greear <greearb@candelatech.com> wrote:
> > > 
> > >> So, this has been asked all over the interweb for years and years, but the best answer I can find is to reboot the system or create a fake NFS server
> > >> somewhere with the same IP as the gone-away NFS server.
> > >> 
> > >> The problem is:
> > >> 
> > >> I have some mounts to an NFS server that no longer exists (crashed/powered down).
> > >> 
> > >> I have some processes stuck trying to write to files open on these mounts.
> > >> 
> > >> I want to kill the process and unmount.
> > >> 
> > >> umount -l will make the mount go a way, sort of.  But process is still hung. umount -f complains: umount2:  Device or resource busy umount.nfs: /mnt/foo:
> > >> device is busy
> > >> 
> > >> kill -9 does not work on process.
> > > 
> > > Kill -1 should work (since about 2.6.25 or so).
> > 
> > That is -[ONE], right?  Assuming so, it did not work for me.
> 
> No, it was "-9" .... sorry, I really shouldn't be let out without my proof
> reader.
> 
> However the 'stack' is sufficient to see what is going on.
> 
> The problem is that it is blocked inside the "VM" well away from NFS and
> there is no way for NFS to say "give up and go home".
> 
> I'd suggest that is a bug.   I cannot see any justification for fsync to not
> be killable.
> It wouldn't be too hard to create a patch to make it so.
> It would be a little harder to examine all call paths and create a
> convincing case that the patch was safe.
> It might be herculean task to convince others that it was the right thing
> to do.... so let's start with that one.
> 
> Hi Linux-mm and fs-devel people.  What do people think of making "fsync" and
> variants "KILLABLE" ??
  Sounds useful to me and I don't see how it could break some
application...

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
