From: "=?iso-8859-1?Q?linux?=" <linux@karasik.org>
Subject: Re: Q: How can I run nfs-utils on MIPS uclibc-based distro	with kernel 2.6?
Date: Wed, 04 Jan 2006 11:34:44 +0000
Message-ID: <20060104113444.6847.qmail@hoster903.com>
Reply-To: "=?iso-8859-1?Q?linux?=" <linux@karasik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eu6un-0002Bd-Gc
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 03:34:49 -0800
Received: from hoster903.com ([66.211.137.15])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1Eu6um-00062z-1j
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 03:34:49 -0800
To: "" <nfs@lists.sourceforge.net>
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

>  -------Original Message-------
>  From: Trond Myklebust <trond.myklebust@fys.uio.no>
>  Subject: Re: [NFS] Q: How can I run nfs-utils on MIPS uclibc-based dis=
tro	with kernel 2.6?
>  Sent: 04 Jan '06 10:58
> =20
>  On Wed, 2006-01-04 at 11:54 +0100, Vincent Roqueta wrote:
>  > Le Mercredi 4 Janvier 2006 11:40, Trond Myklebust a =C3=A9crit :
>  > > On Wed, 2006-01-04 at 10:35 +0000, linux wrote:
>  > > > According to Vincent Roqueta (I received his=A0=A0reply to my pr=
ivate
>  > > > address)=A0=A0 nfs-utils v.1.0.1 shouldn't work with kernels 2.6=
.
>  > >
>  > > ??? Sure it will. 2.6 kernels have legacy support for older versio=
ns of
>  > > both mount and nfs-utils.
>  > Right ... for NFSv3 only?
> =20
>  Yes, for NFSv2 and NFSv3.
> =20
>  NFSv4 needs support from extra daemons and also requires some mountd
>  changes that are more recent.
> =20

Well, NFS server starts and  runs when I use nfs-utils v.1.0.1 with kerne=
l 2.6 (BTW, I compiled nfs-utils without nfsv4 support).
But it runs so slowly and produces tons of errors...
I see two potencial sources for this problem:
- bugs in nfs kernel code in my kernel version (2.6.12)
- interoperability problems between old nfs-utils and new kernel


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
