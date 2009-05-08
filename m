From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problem with NFS and XEN
Date: Fri, 8 May 2009 13:18:46 -0400
Message-ID: <20090508171845.GA19945@fieldses.org>
References: <c4838b6b0905072310g5658ed91i486797b76c8d95d3@mail.gmail.com> <1241785441.19651.28.camel@heimdal.trondhjem.org> <c4838b6b0905080611n3ef3f2efr3e843836b1e3dd@mail.gmail.com> <1241790224.19651.40.camel@heimdal.trondhjem.org> <c4838b6b0905080732v7f693436md49bc6dcdca5d6d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Roger Marcus <roger.marcus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:52954 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbZEHRSp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2009 13:18:45 -0400
In-Reply-To: <c4838b6b0905080732v7f693436md49bc6dcdca5d6d9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 08, 2009 at 04:32:18PM +0200, Roger Marcus wrote:
> Trond:
>=20
> BINGO!!!!
> That was good!
> Thank you thank you.
> Does this mean that if I recreate the subdirectory, I have to do some=
thing to
> re-exportit? like exportfs -a nfsclient:/adir

No, no need.

The kernel has its own cache of the export table, and asks mountd when =
a
client tries to access a filesystem that it doesn't have a cached expor=
t
for.  The "exportfs -f" just flushes that kernels cache, without
changing mountd's idea of which filesystems are exported.

So the next time a client tries to access that filesystem, the kernel
will get the export information back from mountd (and the filesystem
will become busy again).

--b.

>=20
> I will keep going, but that is great so far!
> Thank you very much,
>=20
> Roger Marcus
>=20
> trond:
> Oh, you're using crossmnt to export the subdirectories? In that case,
> why doesn't just 'exportfs -f' suffice to allow you to unmount them?
>=20
>=20
> On Fri, May 8, 2009 at 3:43 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Fri, 2009-05-08 at 15:11 +0200, Roger Marcus wrote:
> >> Hi Trond,
> >>
> >> Thank you for your answer.
> >>
> >> exportfs does not report the individual directories that are mount=
ed
> >> on the exported directory, so I cannot use your script.
> >>
> >> on the nfsserver exports file:
> >> /adir =C2=A0 =C2=A0 192.168.11.129(rw,sync,no_subtree_check,crossm=
nt,no_root_squash)
> >>
> >> on the same machine:
> >> mount -o loop virtual.iso virtualstuff
> >> so now I have /adir/virtualstuff
> >>
> >> (which by the way, I can: =C2=A0umount virtualstuff immediately wi=
thout
> >> problem and it releases.
> >> however, if I run XEN on the client, then the directory is permane=
ntly
> >> locked, ie, umount virtualstuff
> >> DOESN'T work again unless I run exportfs -ua killing all connectio=
ns
> >> to the server.)
> >>
> >> the nfs-client sees /adir/virtualstuff, since parent /adir is moun=
ted.
> >> When I run the virtualmachine within the virtualstuff directory (x=
m
> >> create /adir/virtualstuff/config.cfg)
> >> and then I destroy the virtualmachine (xm destroy /adir/virtualstu=
ff/config.cfg)
> >> I can never 'umount virtualstuff' from the nfsserver, even though =
no
> >> one is accessing the directory
> >> any more.
> >>
> >> So on the nfsserver I cannot umount virtualstuff. this is the bug.
> >>
> >> exportfs -ua =C2=A0 =C2=A0kills nfs for everybody, and then I can =
run 'umount
> >> virtualstuff', but this is not what I want.
> >> exportfs -u nfsclient:/adir =C2=A0 =C2=A0 =C2=A0 doesn't even work=
=2E I don't want this
> >> variation because I might be running 2 virtual machines
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0in two subdirectories.
> >>
> >> question: is the fact that ;exportfs -u nfsclient:/adir' doesn't w=
ork a bug?
> >>
> >> What I want to be able to do is from the nfsserver side, 'umount
> >> virtualstuff', which I can do if I
> >> 1) never run XEN, or
> >> 2) exportfs -ua. The latter command kills all clients attached to =
the server
> >> so I cannot use this second command.
> >> 3) the command 'exportfs -u nfsclient:/adir' doesn't work and this
> >> might be a bug. I do not
> >> want this variant since if I am running 2 virtual machines on the
> >> nfsclient I would kill the other machine.
> >>
> >> In /proc/net/rpc/nfsd.export/content =C2=A0 I see my virtualstuff
> >> subdirectory referenced. Perhaps this
> >> tells you something.
> >>
> >> Thank you in advance,
> >>
> >> Roger Marcus
> >>
> >
> > Oh, you're using crossmnt to export the subdirectories? In that cas=
e,
> > why doesn't just 'exportfs -f' suffice to allow you to unmount them=
?
> >
> > Trond
> >
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
