From: Andrew Theurer <habanero@us.ibm.com>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Mon, 4 Nov 2002 15:13:06 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200211041513.06476.habanero@us.ibm.com>
References: <15808.28897.595522.855723@notabene.cse.unsw.edu.au> <20021101.015623.48537031.taka@valinux.co.jp> <15809.54419.341980.683179@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, "David S. Miller" <davem@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mg03.austin.ibm.com ([192.35.232.20])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 188p2U-0008P5-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Nov 2002 13:45:42 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>,
        Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <15809.54419.341980.683179@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> > I also ported the per-cpu socket patch against linux2.5.45.
>
> I still don't really like this patch.
> I appreciate that some sort of SMP awareness may be appropriate for
> nfsd, but this just doesn't feel right.
>
> Once possibility that I have considered goes like this:
>
> - Allow a (udp) socket to have 'cpu affinity' registered.
> - Get udp_v4_lookup  add to the score for sockets that
>   like the current cpu, and reject sockets that don't like this
>   cpu.
> - Have some cpu affinity with the nfsd threads, probably having
>   a separate idle-server-queue for each cpu.  Possibly half the
>   threads would be tied to a cpu, the other half would float, and
>   only be used if no cpu-local threads were available.

This all sounds great, I wish I knew how to do this :)

> Then instead of have special 'shadow' sockets, we just create NCPUS
> normal udp sockets, instead of one, and give each a cpu affinity.
> This would mean that receiving would benefit from multiple sockets
> as well as sending.

So, the target socket getting populated on inbound traffic would likely d=
epend=20
on which CPU took the net card inturrupt?  And the resulting CPU would ha=
ndle=20
the NFS request?  If so, and you had a good interrupt balance across CPUs=
,=20
that sounds fine.  If you have an interrupt imbalance, it could be really=
=20
bad.  This doesn't sound like a problem on a system like PIII, where=20
interrupts can float (don't know how irqbalance works with that) but I'm =
not=20
so sure about P4, even with irqbalance.  Over time they do balance out, b=
ut=20
in my experience a particular interrupt is being handled by one CPU or=20
another with a significant (in this context) amount of time between=20
destination changes.=20

> I have very little experience with these sort of SMP issues, so I may
> be missing something obvious, but to me, this approach seems cleaner
> and more general.
>
> Dave: what would you think of having a "unsigned long cpus_allowed"
> in struct inet_opt and putting the appropriate checks in
> udp_v4_lookup??  Is it worth experimenting with?
>
> NeilBrown



-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
