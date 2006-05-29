From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: 2.4 vs 2.6
Date: Mon, 29 May 2006 01:52:51 -0700 (PDT)
Message-ID: <20060529085251.71517.qmail@web51613.mail.yahoo.com>
References: <17530.36039.227704.325645@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: mehta kiran <kiranmehta1981@yahoo.com>,
	nfs@lists.sourceforge.net, Vijay Chauhan <kernel.vijay@gmail.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FkdUf-0007aT-OX
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 01:52:57 -0700
Received: from web51613.mail.yahoo.com ([68.142.224.86])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FkdUf-00014n-9y
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 01:52:57 -0700
To: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <17530.36039.227704.325645@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



--- Neil Brown <neilb@suse.de> wrote:

> On Friday May 26, bfields@fieldses.org wrote:
> > On Fri, May 26, 2006 at 01:19:05AM -0700, mehta
> kiran wrote:
> > > Hi,
> > >=20
> > > 1. I noticed that 2.6 kernel is not aware of=20
> > >    exportfs until client tries to mount. It only
> > >    after this that proc nfsd filesystem shows
> this
> > >    in list of exports due to upcall.
> > >    Was 2.4 kernel aware of exportfs when the
> > >    filesystem was first exported or mounted ?
> > >=20
> > > 2. Can you let me know advantage 2.6 export
> approach
> > >    over 2.4 export approach ?=20
> > >    Is this approach required due to=20
> > >    security/authentication integration with
> NFS(say=20
> > >    ip->name conversion for security ) ?
> >=20
> > The kernel has to know whether an incoming IP
> address matches, say,
> > "*.umich.edu."  But we don't want to add an entire
> DNS client
> > implementation to the kernel.  And we also can't
> preload the kernel with
> > every possible IP address that might match
> *.umich.edu.  So we allow
> > the kernel to ask mountd for that information when
> it needs it.
> >=20
> > This isn't actually necessary for an NFSv2/v3
> server, because mountd
> > always gets a "mount" request from any client
> before the kernel gets any
> > NFS requests from that client, so mountd can tell
> the kernel about the
> > new client then.
>=20
> Not exactly necessary, but without it we depend on
> 'rmtab' to record
> which clients have the filesystem mounted across a
> server reboot, and
> it is not possible to maintain an rmtab file
> reliably.
>=20
> >=20
> > But NFSv4 clients don't contact mountd first.=20
> Neither do v2/v3 clients
> > that are failing over from another server.  So you
> need the upcalls to
> > handle those cases.
> >=20
> > That justifies the auth_unix_ip upcall, anyway;
> I'm less sure about the
> > others.
>=20
> The nfsd.fh upcall - which maps a
> file-handle-fragment to a directory -
> can be used to implementing on-demand loading of
> filesystems,
> e.g. CDroms from a CD library.  We don't actually do
> that now, but we
> could.
> It also means that if a filesystem isn't currently
> being used by a
> client, (where 'currently' means in the last 30
> minutes I think), then
> you can unmount it without having to unexport it.=20
> This is (arguably?)
KM>
1.I tried this but got to know that exported   =20
  filesystem may not be umounted cleanly when client
  has mounted that fs atleast once in past.
  Is this expected ? Looks like kernel
  holds reference to exported fs
2.Just a thought ....
  Consider a case where server exports a filesystem
  (and nobody mounts it for long time)=20
  and due to inactivity on it for some time, it
  umounts the filesystem. Now if some new client
  tries to mount it, it may access some data(data on=20
  mount point) which server  may not have exported,=20
  right ?



> a good thing.
>=20
> nfsd.export is needed because once auth.unix.ip and
> nfsd.fh have
> provided their information - it combines the two
> together to get
> export options.
>=20
> auth.domain was a mistake that is gone in recent
> kernels.
>=20
> That leaves nfs4.nametoid and nfs4.idtoname.  I'm
> sure they do
> something useful.... :-)
>=20
> Hope that completes the clarification.
>=20
> NeilBrown
>=20


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications i=
n
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D107521&bid=3D248729&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
