From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: nfs export from mount point with --bind ?
Date: Wed, 10 May 2006 04:34:31 -0700 (PDT)
Message-ID: <20060510113431.15419.qmail@web51604.mail.yahoo.com>
References: <44618C81.5050503@vwi.tu-dresden.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fdmxh-0005MG-On
	for nfs@lists.sourceforge.net; Wed, 10 May 2006 04:34:37 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fdmxh-0001RE-NM
	for nfs@lists.sourceforge.net; Wed, 10 May 2006 04:34:37 -0700
Received: from web51604.mail.yahoo.com ([206.190.38.209])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Fdmxh-0003Nq-0Z
	for nfs@lists.sourceforge.net; Wed, 10 May 2006 04:34:37 -0700
To: kolbe@vwi.tu-dresden.de, nfs@lists.sourceforge.net
In-Reply-To: <44618C81.5050503@vwi.tu-dresden.de>
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

Try exporting with "nohide" option. That would make
children filesystem visible to client.

--- Steffen Kolbe <kolbe@vwi.tu-dresden.de> wrote:

> A server has mounted some luns (partitions) from a
> fc-storage to different
> mount points in the system.
> These are mounted for export via 'mount --bind'
> under an /export folder.
> Is it possible to export only these /export folder
> via NFS or can I only=20
> export
> every "sub mount point (=3D --bind) in /exports" with
> the NFS kernel server?
>=20
> The user server can this, but he hangs some times
> (Debian AMD64). So I=20
> changed
> to the kernel server whitch works stable. But he
> seems not to export=20
> folders
> which are mounted via --bind under a "master
> export". If I mount these=20
> master
> folder to a client, the folder is empty.
>=20
> Is their a solutions or special option for this
> available?
>=20
> Thanks
> Steffen
>=20
>=20
>
-------------------------------------------------------
> Using Tomcat but need to do more? Need to support
> web services, security?
> Get stuff done quickly with pre-integrated
> technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1
> based on Apache Geronimo
>
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D=
121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job ea=
sier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronim=
o
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
