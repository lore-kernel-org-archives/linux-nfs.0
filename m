From: Simeon Miteff <simeon@up.ac.za>
Subject: Re: Problem starting rpc.svcgssd for NFS4
Date: Tue, 24 Feb 2004 11:00:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402241100.13391.simeon@up.ac.za>
References: <200402230759.35041.simeon@up.ac.za> <20040223162516.GA4977@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvYRd-00086t-8g
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 01:01:37 -0800
Received: from kendy.up.ac.za ([137.215.101.101])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AvYF3-0007eM-Bu
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 00:48:40 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <20040223162516.GA4977@fieldses.org>
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

Hi again,

Thanks! Applying the patch solved the problem. I can mount exports with 
-osec=krb5 and stuff.

The main reason why I want to use NFS4 is for the security it provides. While 
I understand that NFS4 isn't concidered ready for production systems yet, I'm 
wondering, is it a good idea to use -osec=krb5 with NFS3 in the mean-time?

Regards,
Simeon.

On Monday 23 February 2004 18:25, J. Bruce Fields wrote:
> On Mon, Feb 23, 2004 at 07:59:35AM +0200, Simeon Miteff wrote:
> > I'm using kernel 2.6.3, the patched util-linux and nfs-utils, my
> > kerberos5 setup is working (tested with openssh), and so far I've done
> > everything as described by
> > http://www.citi.umich.edu/projects/nfsv4/linux/, yet I get this problem
> > when I try to start rpc.svcgssd:
> >
> > Feb 20 08:39:11 io gssd[25729]: Using (default) Kerberos realm:
> > "EE.UP.AC.ZA" Feb 20 08:39:11 io gssd[25729]: Initialized credentials
> > cache
> > Feb 20 08:39:11 io gssd[25729]: Using credentials cache:
> > "FILE:/tmp/krb5cc_machine"
> > Feb 20 08:39:11 io gssd[25729]: Acquired initial kerberos ticket
> > Feb 20 08:39:11 io gssd[25729]: failed to
> > open /proc/net/rpc/auth.rpcsec.init/channel
> >
> > Looking in that directory:
> >
> > simeon@io rpc $ ls -l /proc/net/rpc/
> > total 0
> > dr-xr-xr-x    2 root     root            0 Feb 23 07:57 auth.domain
> > dr-xr-xr-x    2 root     root            0 Feb 20 08:38 auth.unix.ip
> > -r--r--r--    1 root     root            0 Feb 23 07:57 nfs
> > -r--r--r--    1 root     root            0 Feb 23 07:57 nfsd
> > dr-xr-xr-x    2 root     root            0 Feb 20 08:38 nfsd.export
> > dr-xr-xr-x    2 root     root            0 Feb 20 08:38 nfsd.fh
> >
> > Any Ideas why /proc/net/rpc/auth.rpcsec.init/channel is missing? I double
> > checked the kernel config options...
>
> Are you using the kernel.org 2.6.3?  It has no support for rpcsec_gss on
> the server side.  We're working with Neil to get that in; it should
> happen soon.  For now, you could test with our CITI_NFS4_ALL patch,
>
> http://www.citi.umich.edu/projects/nfsv4/linux/
>
> --Bruce Fields
>
>
> -------------------------------------------------------
> SF.Net is sponsored by: Speed Start Your Linux Apps Now.
> Build and deploy apps & Web services for Linux with
> a free DVD software kit from IBM. Click Now!
> http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
Mr Simeon Miteff
Department of Electrical, Electronic and Computer Engineering
University of Pretoria
Pretoria
0002
South Africa
Tel: +27 12 420 2434
-----------------------------------------------
This message and attachments are subject to a disclaimer. Please refer
to www.it.up.ac.za/documentation/governance/disclaimer/ for details.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
