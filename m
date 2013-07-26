Return-Path: linux-nfs-owner@vger.kernel.org
Received: from pfw.demon.co.uk ([62.49.22.168]:45616 "EHLO pfw.demon.co.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757956Ab3GZWZR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jul 2013 18:25:17 -0400
Date: Fri, 26 Jul 2013 22:25:10 +0000
From: Larry Keegan <lk@pfw.demon.co.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, Larry Keegan <lk@pfw.demon.co.uk>,
        <linux-nfs@vger.kernel.org>
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130726222510.793c1627@cs3.al.itld>
In-Reply-To: <20130726150222.GC30651@fieldses.org>
References: <20130725134515.67af44e2@cs3.al.itld>
 <20130725101143.6a22cb81@corrin.poochiereds.net>
 <20130725170526.6e54c7db@cs3.al.itld>
 <20130725141828.1862a1e1@tlielax.poochiereds.net>
 <20130726124101.058df8dc@cs3.al.itld>
 <20130726091225.5f299ff6@corrin.poochiereds.net>
 <20130726150222.GC30651@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 26 Jul 2013 11:02:22 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Fri, Jul 26, 2013 at 09:12:25AM -0400, Jeff Layton wrote:
> > On Fri, 26 Jul 2013 12:41:01 +0000
> > Larry Keegan <lk@pfw.demon.co.uk> wrote:
> > > I now have a good and a bad packet capture. I can run them through
> > > tshark -V but if I do this, they're really long, so I'm wondering
> > > how best to post them. I've posted the summaries below.
> > > 
> > > The set-up is as follows: I'm running a few xterms on my desktop
> > > (the affected client) as well as claws-mail using the mailmbox
> > > plugin. Claws keeps a cache of the mailbox
> > > in .clawsmail/tagsdb/<foldername>. From time to time I blast a
> > > load of mail into these mail boxes using procmail. This seems to
> > > demonstrate the problem most of the time. After a few minutes
> > > everything gets back to normal.
> > > 
> > > The actual mail is being delivered on my file server pair directly
> > > into /home/larry/Mail/<foldername>. Both file servers use
> > > automount to mount the same filesystem
> 
> Wait, I'm confused: that sounds like you're mounting the same ext4
> filesystem from two different machines?
> 
> --b.
> 

Dear Bruce,

I'm sorry, I didn't express myself clearly enough. I described my
server-side NFS arrangements a few hours ago in a note to Jeff Layton.
(I'm afraid I didn't catch your email until just now - NFS problems,
you know). In summary, whereas I do have two NFS servers, only one has
the filesystems mounted and exported at a time. The other just sees the
underlying drbd device in secondary mode. It merely keeps the data on
the block device up-to-date for when I cut over to it. I pretty much
never do this unless I wish to reboot the active NFS server. To all
intents and purposes, I only have one NFS server. I purposefully didn't
use primary-primary drbd replication with OCFS or GFS2 because it
was all too new when I set this up.

As far as NFS client arrangements are concerned, both of the NFS server
machines also function as NFS clients, so /home/larry works on them in
the same way as it does on any other NFS client on the network. It is
just that the NFS servers also run my postfix MTAs. In turn, postfix
delivers mail to my (multiple) inboxes under /home/larry/Mail/whatever.

Mail comes in from my perimeter mail boxes is in round-robin fashion to
both the NFS server/client/postfix MTA machines, so inevitably yes, both
of these machines automount /home/larry most of the time, but this is no
different from, say my desktop computer which is also
mounting /home/larry.

The point about email delivery is that in this arrangement both my NFS
server computers, with purely their NFS client hats on, contend to
deliver messages into the same mail files on the same filesystem served
by just one NFS server. For instance, the linux-nfs mailing list traffic
all goes into one file. This often causes a lot of thumb-twiddling
whilst the procmails try to get the lock on the mail file. It's all
happens too fast for me to notice, but I'm sure procmail would rather
be sunning itself on the beach or something.

The reason why email delivery seems to be a pretty consistent trigger
for this problem is: a) there's bugger all else going on with all these
NFS problems, b) the fact that the two NFS server/client/postfix boxes
and claws-mail on my desktop box are all investigating and modifying
the same files all the time, and c) I'm deliberately holding back
inbound mail and releasing it in large batches to try to exercise this
problem.

The odd thing is that I haven't (yet) had any problems with the
mailboxes themselves, only the state-files and caches that claws mail
keeps under /home/whatever/.clawsmail. These are only ever accessed
from my desktop machine.

Yours,

larry
