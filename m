Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48832 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750765AbdEPQdW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 May 2017 12:33:22 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKdf4aKRRMJWLERr8hE7kptighaqFtR0vWdoMkPraSsYpw@mail.gmail.com>
References: <CAOssrKdf4aKRRMJWLERr8hE7kptighaqFtR0vWdoMkPraSsYpw@mail.gmail.com> <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk> <149486154888.23956.10260643844119198576.stgit@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/21] VFS: Introduce a superblock configuration context [ver #3]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 16 May 2017 17:33:18 +0100
Message-ID: <18741.1494952398@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> One way to split this large patch up into more managable chunks would be:
> 
>  1) common infrastructure
>  2) new mount related changes
>  3) reconfig (remount) related changes
> 
> Would that work?

The problem is that remount seems to generally use the same parsing code as
the new-mount entry point.

Before considering how to split it, can we consider whether to roll patches 20
and 21 into the preceding patches?

>   (a) new mount with new super block created
>   (b) new mount with existing super block reused
>   (c) remount

(b) is internal-only at the moment, used by NFS submounts as triggered by
automounts.  There isn't currently any way to supply mount options to this.

>   2) modify options ("foo" turns option on, "nofoo" turns it off)

Not all options are binary and some options may be mandatory.

> The surprising thing here is that we do (a) and (b) via the same route
> and (a) and (c) via a different ones.  This doesn't feel right.

You need to look at it like this:

	Case	Options	Ref	Call	Modify
		        super	sget	super
	=======	=======	=======	=======	=======
	a	Y	-	Y	-
	b	-	Y	Y	-
	c	Y	[1]	-	Y

[1] We don't have a separate reference sb, only the one we're going to modify,
    but we can preload the sb_config from that.

(a) and (b) have the same action.

>   i) options that determine the sb instance (such as the blockdev or
> the server IP address)
>   ii) subpath: this can determine the sb as well as the subtree to use
>   iii) options that can be changed while sb in use
>   iv) ???

Ah - but some of these options have to be set *inside* sget() or before the
superblock becomes live, even the ones that can be changed in-flight.

> Would it make sense to make the "new mount" case be
> 
>   A) find or create sb based on (i) and (ii) options
>   B) reconfigure the resulting sb based on (iii) options

You would *have* to do the reconfiguration before making the superblock live
to prevent config/use races, and some options in (iii) may be required during
sget(), or even before you get as far as calling sget() (say you need to
access a server).

> This would make legacy new mount be: (A) + if new then (B).  And
> legacy remount just (B).

It's not obvious that this is sufficiently equivalent from your brief
description.

> Also I think silently ignoring options is not always the right answer.

Example?

Do you mean like the NFS 'sloppy' option?  I've noted that that might be best
handled in userspace.

> > +       int (*remount_fs_sc) (struct super_block *, struct sb_config *);
> 
> How about reconfig_fs() or just reconfig()?

Sure.

> > + (*) struct dentry *(*mount)(struct sb_config *sc);
> 
> I'd be much happier with "get_root()" or something.

Changed in patch 21 to ->get_tree() as suggested by Al.  Having looked over
the code, I'm tempted to change it back to ->mount() as being more obvious.

> > +               err = parse_monolithic_mount_data(sc, data);
> > +               if (err < 0)
> > +                       goto err_sc;
> 
> If filesystem defines ->monolithic_mount_data() who is responsible for
> calling the security hook?

Which security hook?  security_sb_remount()?

Note this code has changed in patch 20.  I should update security_sb_remount()
to take an sb_config and call it in all paths.

> Largely duplicated do_new_mount_sc().  What's the point?

Legacy vs new.  Fixed in patch 20.

> Lots of these are not superblock options, and should be moved over to
> the forbidden ones.  Look at do_mount() for a hint.

I still have to support legacy mount option parsing.  Do I actually see these
in legacy mount(2)?  Or are they weeded out by mount(8)?

David
