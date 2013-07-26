Return-Path: linux-nfs-owner@vger.kernel.org
Received: from pfw.demon.co.uk ([62.49.22.168]:49978 "EHLO pfw.demon.co.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757043Ab3GZQKw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jul 2013 12:10:52 -0400
Date: Fri, 26 Jul 2013 16:10:46 +0000
From: Larry Keegan <lk@pfw.demon.co.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130726161046.00c19730@cs3.al.itld>
In-Reply-To: <20130726091225.5f299ff6@corrin.poochiereds.net>
References: <20130725134515.67af44e2@cs3.al.itld>
 <20130725101143.6a22cb81@corrin.poochiereds.net>
 <20130725170526.6e54c7db@cs3.al.itld>
 <20130725141828.1862a1e1@tlielax.poochiereds.net>
 <20130726124101.058df8dc@cs3.al.itld>
 <20130726091225.5f299ff6@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 26 Jul 2013 09:12:25 -0400
Jeff Layton <jlayton@redhat.com> wrote:
> On Fri, 26 Jul 2013 12:41:01 +0000
> Larry Keegan <lk@pfw.demon.co.uk> wrote:
> 
> > On Thu, 25 Jul 2013 14:18:28 -0400
> > Jeff Layton <jlayton@redhat.com> wrote:
> > > On Thu, 25 Jul 2013 17:05:26 +0000
> > > Larry Keegan <lk@pfw.demon.co.uk> wrote:
> > > 
> > > > On Thu, 25 Jul 2013 10:11:43 -0400
> > > > Jeff Layton <jlayton@redhat.com> wrote:
> > > > > On Thu, 25 Jul 2013 13:45:15 +0000
> > > > > Larry Keegan <lk@pfw.demon.co.uk> wrote:
> > > > > 
> > > > > > Dear Chaps,
> > > > > > 
> > > > > > I am experiencing some inexplicable NFS behaviour which I
> > > > > > would like to run past you.
> > > > > What might be helpful is to do some network captures when the
> > > > > problem occurs. What we want to know is whether the ESTALE
> > > > > errors are coming from the server, or if the client is
> > > > > generating them. That'll narrow down where we need to look
> > > > > for problems.
> > > Ok, we had a number of changes to how ESTALE errors are handled
> > > over the last few releases. When you mentioned 3.10, I had
> > > assumed that you might be hitting a regression in one of those,
> > > but those went in well after the 3.4 series.
> > > 
> > > Captures are probably your best bet. My suspicion is that the
> > > server is returning these ESTALE errors occasionally, but it
> > > would be best to have you confirm that. They may also help make
> > > sense of why it's occurring...
> > I now have a good and a bad packet capture. I can run them through
> > tshark -V but if I do this, they're really long, so I'm wondering
> > how best to post them. I've posted the summaries below.
> > 
> > The first thing that strikes me is the bad trace is much longer.
> > This strikes me as reasonable because as well as the ESTALE problem
> > I've noticed that the whole system seems sluggish. claws-mail is
> > particularly so because it keeps saving my typing into a drafts
> > mailbox, and because claws doesn't really understand traditional
> > mboxes, it spends an inordinate amount of time locking and unlocking
> > the boxes for each message in them. Claws also spews tracebacks
> > frequently and it crashes from time to time, something it never did
> > before the ESTALE problem occurred.
> I'm afraid I can't tell much from the above output. I don't see any
> ESTALE errors there, but you can get similar issues if (for instance)
> certain attributes of a file change.

Such as might occur due to mail delivery?

> You mentioned that this is a DRBD
> cluster, are you "floating" IP addresses between cluster nodes here?
> If so, do your problems occur around the times that that's happening?
> 
> Also, what sort of filesystem is being exported here?
> 
The way my NFS servers are configured is as follows:

I have two identical boxes. They run lvm. There are two lvs on each
box called outer-nfs0 and outer-nfs1. These are kept in sync with drbd.
The content of these volumes are encrypted with dmcrypt. The plaintext
of each volume is a pv. I have two inner volume groups, named nfs0 and
nfs1. These each contain one of those pvs. They are sliced into a dozen
or so lvs. The lvs each contain ext4 filesystems. Each filesystem
contains one or more home directories. Although each filesystem is
exported in its entirety, autofs only mounts subdirectories (for
example /home/larry on fs-nfs0:/export/nfs0/home00/larry). Exports are
arranged by editing the exports file and running 'exportfs -r' so
userspace is always in sync with the kernel.

Each nfs volume group is associated with its own IP address which is
switched along with the volume group. So, when one of my boxes can see
volume group nfs0 it will mount the volumes inside it and export all the
filesystems on that volume group via its own ip address. Thus, one
fileserver can export nothing, a dozen filesystems or two dozen
filesystems. The automounter map only ever refers to the switchable ip
addresses.

This arrangement keeps the complexity of the dmcrypt stuff low and is
moderately nippy. As for the switchover, I've merely arranged pacemaker
to 'ip addr del' and 'ip addr add' the switchable IP addresses, blast
out a few ARPs and Bob's you're uncle. Occasionally I get a machine
which hangs for a couple of minutes, but mostly it's just a few
seconds. Until recently I haven't seen ESTALE errors.

The way I see it, as far as our discussion goes, it looks like I have a
single NFS server with three IP addresses, and the server happens to
copy its data to another server just in case. I haven't switched over
since I last upgraded.

Having said that, I can see where you're coming from. My particular
configuration is unnecessarily complicated for testing this problem.
I shall configure some other boxes more straightforwardly and hammer
them. Are there any good nfs stress-tests you can suggest?

Yours,

Larry.
