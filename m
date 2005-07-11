From: Daniel McNeil <daniel@osdl.org>
Subject: RE: [PATCH 2/3]: NFS: use atomic bitops to manipulate flags
	in nfsi->flags
Date: Mon, 11 Jul 2005 16:43:23 -0700
Message-ID: <1121125403.3150.27.camel@ibm-c.pdx.osdl.net>
References: <482A3FA0050D21419C269D13989C611307CF4CF8@lavender-fe.eng.netapp.com>
	 <1121121546.16899.1.camel@lade.trondhjem.org>
	 <1121123616.3150.22.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	"NIck Wilson (work)" <njw@osdl.org>,
	"Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ds7vr-0005Ha-Tk
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 16:43:27 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Ds7vr-0004Vx-NF
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 16:43:28 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121123616.3150.22.camel@ibm-c.pdx.osdl.net>
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

On Mon, 2005-07-11 at 16:13, Daniel McNeil wrote:
> On Mon, 2005-07-11 at 15:39, Trond Myklebust wrote:
> > m=C3=A5 den 11.07.2005 Klokka 14:53 (-0700) skreiv Lever, Charles:
> > > > > +
> > > > >  	atomic_inc(&inode->i_count);
> > > > > -	error =3D nfs_wait_event(clnt, nfsi->nfs_i_wait,
> > > > > -				!(NFS_FLAGS(inode) & flag));
> > > > > +	rpc_clnt_sigmask(clnt, &oldmask);
> > > > > +	error =3D wait_on_bit_lock(&nfsi->flags, NFS_INO_REVALIDATING=
,
> > > > > +					nfs_wait_schedule,=20
> > > > TASK_INTERRUPTIBLE);
> > > >=20
> > > >                                                              =20
> > > >   ^^^^^^^^^^^^^
> > > > Shouldn't this depend on whether the client mounted with intr?
> > >=20
> > > roughly the same logic is used in net/sunrpc/sched.c:__rpc_execute,=
 and
> > > it doesn't observe the intr flag either.  perhaps it is an ommissio=
n
> > > there too?
> >=20
> > rpc_clnt_sigmask() should offer sufficient protection.
> >=20
>=20
> This use to call nfs_wait_event() which checked clnt->cl_intr
> and called wait_event() or wait_event_interruptible().
> It looks like rpc_clnt_sigmask() will allow SIGKILL to
> wake up the task.  Is that ok if the client is not mounted
> with intr?


Sorry for replying to my own email, but I was look in 2.6.12.
The code in 2.6.13-rc2 does not allow SIGKILL, so rpc_clnt_sigmask()
does offer sufficient protection.

Daniel



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
