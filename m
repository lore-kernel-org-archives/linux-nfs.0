From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Fri, 1 Nov 2002 12:10:43 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15809.54419.341980.683179@notabene.cse.unsw.edu.au>
References: <15808.28897.595522.855723@notabene.cse.unsw.edu.au>
	<20021031.110659.42769812.taka@valinux.co.jp>
	<20021101.004052.85418463.taka@valinux.co.jp>
	<20021101.015623.48537031.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, "David S. Miller" <davem@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187QKx-0008Dc-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 17:10:59 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>)
	(for <davem@redhat.com>) By tone With Smtp ;
	Fri, 1 Nov 2002 12:10:48 +1100
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday November 1
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

On Friday November 1, taka@valinux.co.jp wrote:
> Hello,
> 
> > > The rest of the zero copy stuff should fit in quite easily, with the
> > > possible exception of single-copy writes: I haven't looked very hard
> > > at that yet.
> > 
> > I just ported part of the zero copy stuff against linux-2.5.45.
> > single-copy writes and per-cpu sokcets are not included yet.
> > And I fixed a problem that NFS over TCP wouldn't work. 
> 
> I also ported the per-cpu socket patch against linux2.5.45.
> 

I still don't really like this patch.
I appreciate that some sort of SMP awareness may be appropriate for
nfsd, but this just doesn't feel right.

Once possibility that I have considered goes like this:

- Allow a (udp) socket to have 'cpu affinity' registered.
- Get udp_v4_lookup  add to the score for sockets that
  like the current cpu, and reject sockets that don't like this
  cpu.
- Have some cpu affinity with the nfsd threads, probably having
  a separate idle-server-queue for each cpu.  Possibly half the
  threads would be tied to a cpu, the other half would float, and
  only be used if no cpu-local threads were available.

Then instead of have special 'shadow' sockets, we just create NCPUS
normal udp sockets, instead of one, and give each a cpu affinity.
This would mean that receiving would benefit from multiple sockets
as well as sending.

I have very little experience with these sort of SMP issues, so I may
be missing something obvious, but to me, this approach seems cleaner
and more general.

Dave: what would you think of having a "unsigned long cpus_allowed"
in struct inet_opt and putting the appropriate checks in
udp_v4_lookup??  Is it worth experimenting with?

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
