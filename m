From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Question on NFS server timing out
Date: Wed, 25 Jun 2003 07:36:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127E58@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19VBOh-0007oS-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 07:37:19 -0700
To: "Steve Wolfe" <sn@codon.com>
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

> > If you are getting I/O errors from cat then you are presumably
> > mounting with the "soft" option.  This is almost always wrong.  Use
> > hard,intr.
>=20
>   The reason I used soft was because when the NFS server would have a
> hiccup, CGI apps would pile up on all of the web servers, and=20
> never exit.
> But I guess I'll have to live with that and use hard. : )

you can do better with soft if you think you really need
to use it.  try:

   soft,retrans=3D50,intr

this causes the client to try a lot harder before giving
up and timing out an RPC request.

we don't like the soft mount option, as neil says, but in
some cases it is a necessary evil.  the Linux NFS FAQ has
more information on this.

but "soft" in your case is simply a workaround.  the real
problem, obviously, is getting your server not to hiccup. =20

> > I'm guessing that the high load during the days is a=20
> read-mostly load.
> > moving the log files in a write-mostly load.  Presumably your nfs
> > server isn't coping with writes as fast as you would like.
> >
> > You are probably using the "sync" export option.  This is normally a
> > good thing.  However if you are happy to risk loosing=20
> recently written
> data if
> > the fileserver crashes (which you might be in your situation) you
> > could replace "sync" with "async" and get faster writes.
>=20
>   No 'sync', the options have been:
>=20
> exec,nodev,nosuid,rw,soft,rsize=3D8192,wsize=3D8192,intr
>=20
> and replaced with:
>=20
> exec,nodev,nosuid,rw,hard,rsize=3D8192,wsize=3D8192,intr

these are mount options.  neil meant the "sync" *export*
option the server.  what are your server's export options?


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
