From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: rpc.mountd stops functioning
Date: Mon, 30 Aug 2004 15:54:08 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16690.49408.762551.914134@cse.unsw.edu.au>
References: <411217BE.8070209@framestore-cfc.com>
	<20040805144659.GD25948@fieldses.org>
	<16686.43784.910598.870375@cse.unsw.edu.au>
	<20040827231654.GA2836@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1f7a-0003M9-O7
	for nfs@lists.sourceforge.net; Sun, 29 Aug 2004 22:54:26 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C1f7a-0003Cl-0S
	for nfs@lists.sourceforge.net; Sun, 29 Aug 2004 22:54:26 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Friday August 27
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

On Friday August 27, bfields@fieldses.org wrote:
> On Fri, Aug 27, 2004 at 01:31:20PM +1000, Neil Brown wrote:
> > I don't think this patch is needed (though it wouldn't actually bre=
ak anything).
> > The loop in svc_run.c starts:
> >=20
> >=20
> > =09=09readfds =3D svc_fdset;
> > =09=09cache_set_fds(&readfds);
> >=20
> > so readfds is completely initialised at the top of the loop, so
> > clearing something at the bottom (which is essentially what this pa=
tch
> > does) should be a no-op.
> >=20
> > Am I wrong?
>=20
> Note that cache_process_req() (which the patch below modifies) is not=

> all the way at the bottom of the loop; there's still an importan call=
 to
> svc_getreqset() after it.
>=20
> If I understand the problem correctly, what happens is that if select=
()
> returns with a set that includes two file descriptors, the first for =
a
> cache channel and the second for an rpc socket, and if we don't clear=

> the first file descriptor from that set before passing it to
> svc_getreqset(), then the rpc code will try to read an rpc request fr=
om
> a cache channel file, and will get very confused.

Ahh, I get it now, thanks.

This is really a bug in glibc.   A relevant piece of code reads:
  xprt =3D xports[fd];
  /* Do we control fd? */
  if (xprt =3D=3D NULL)
     return;

so unknown file descriptors should be ignored.  However xports is
allocated thus:
  if (xports =3D=3D NULL)
    {
      xports =3D (SVCXPRT **) malloc (_rpc_dtablesize () * sizeof (SVCX=
PRT *));
      if (xports =3D=3D NULL) /* Don=B4t add handle */
=09return;
    }

and so is not NULL-filled !!

In any case, you suggested change is good defensive programming and I
will add it.

Thanks.
NeilBrown



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
