From: Douglas Furlong <douglas.furlong@firebox.com>
Subject: Re: NFS server not responding
Date: Fri, 28 Nov 2003 09:37:09 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1070012227.3615.7.camel@wibbit.firebox.com>
References: <1069934421.4677.77.camel@wibbit.firebox.com>
	 <200311280946.06755.jojo@automatix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APf4C-0006Ki-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 01:37:36 -0800
Received: from dsl-217-155-91-196.zen.co.uk ([217.155.91.196] helo=helium.firebox.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.24)
	id 1APf4B-00038i-Tm
	for nfs@lists.sourceforge.net; Fri, 28 Nov 2003 01:37:36 -0800
Received: from localhost (helium.firebox.com [127.0.0.1])
	by helium.firebox.com (8.12.8/8.12.8) with ESMTP id hAS9UA9e008231
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 09:30:10 GMT
Received: from helium.firebox.com ([127.0.0.1])
 by localhost (helium.firebox.com [127.0.0.1]) (amavisd-new, port 10024)
 with LMTP id 07910-03-3 for <nfs@lists.sourceforge.net>;
 Fri, 28 Nov 2003 09:30:10 +0000 (GMT)
Received: from [192.168.0.150] (wibbit.firebox.com [192.168.0.150])
	by helium.firebox.com (8.12.8/8.12.8) with ESMTP id hAS9TlUh008196
	for <nfs@lists.sourceforge.net>; Fri, 28 Nov 2003 09:29:47 GMT
To: nfs@lists.sourceforge.net
In-Reply-To: <200311280946.06755.jojo@automatix.de>
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

On Fri, 2003-11-28 at 08:46, Juergen Sauer wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> Am Donnerstag, 27. November 2003 13:00 schrieb Douglas Furlong:
> > Good day all.
> >=20
> > I am running in to excessive amounts of NFS errors as below.
> >=20
> > kernel: nfs: server neon not responding, still trying
> > kernel: nfs: server neon OK
> >=20
> > I was hoping that some of you may be able to provide me with some
> > assistance.
>=20
> Hight Doug, Hi Trond,
>=20
> Is there any NVIDIA Stuff in the client/server ?
> The Nvidia drivers vor the graphics and the nvidia netdrivers
> are broken for 2.4.[20|21|22] !
> The nv.o module for Xfree86 breaks IMHO the NFS.
>=20
> I sent a bug report to the Nvidia maintainers.
>=20
> Refer to the NFS Server not responding threads in the last month.

Morning J=FCrgen

I do indeed have an nvidia card in the machine which is a nVidia
Corporation NV11 [GeForce2 MX/MX 400] (rev b2).

However on an lsmod the nv.o driver is not being loaded (the machine
goes to run level 3 not 5.

Am I right in saying this should mean the problem does not exist?

I will go and have a look at those archives (only been on the list for a
week).

Doug



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
