From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS issues with recent kernels [long]
Date: Fri, 08 May 2009 16:48:55 -0400
Message-ID: <1241815735.7291.1.camel@heimdal.trondhjem.org>
References: <20090417102659.GC55096@fuchs>
	 <B05C16C7-53B5-4E26-8239-956C600CF452@oracle.com>
	 <20090420091454.GB614@fuchs>
	 <F1250240-F050-47B7-9569-54941AAAD572@oracle.com>
	 <20090421043642.GA52257@fuchs> <20090508193813.GC3801@fuchs>
	 <8D7394C9-0142-4635-88E5-139F4F5F39F6@oracle.com>
	 <20090508203751.GD3801@fuchs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>
To: =?ISO-8859-1?Q?Andr=E9?= Berger <andre.berger-S0/GAf8tV78@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:39485 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763620AbZEHUs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2009 16:48:58 -0400
In-Reply-To: <20090508203751.GD3801@fuchs>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-08 at 22:37 +0200, Andr=C3=A9 Berger wrote:
> * Chuck Lever (2009-05-08):
> > On May 8, 2009, at 3:38 PM, Andr=C3=A9 Berger wrote:
> >> * Andr=C3=A9 Berger (2009-04-21):
> >>> * Chuck Lever (2009-04-20):
> >>>> On Apr 20, 2009, at 5:14 AM, Andr=C3=A9 Berger wrote:
> >>>>> * Chuck Lever (2009-04-17):
> [...]
> > Assuming 192.168.1.8 is your server, frame 79 and 622 report FSINFO=
 =20
> > results:
> >
> > Network File System, FSINFO Reply
> >     [Program Version: 3]
> >     [V3 Procedure: FSINFO (19)]
> >     Status: NFS3_OK (0)
> >     obj_attributes
> >         attributes_follow: no value (0)
> >     rtmax: 16384
> >     rtpref: 16384
> >     rtmult: 4096
> >     wtmax: 16384
> >     wtpref: 16384
> >     wtmult: 4096
> >     dtpref: 4096
> >     maxfilesize: 2194719883264
> >     time delta: 1.000000000 seconds
> >         seconds: 1
> >         nano seconds: 0
> >     Properties: 0x0000001b
> >         1... . =3D SETATTR can set time on server
> >         .1.. . =3D PATHCONF is valid for all files
> >         ...1 . =3D File System supports symbolic links
> >         .... 1 =3D File System supports hard links
> >
> > says your server operating system supports NFS rsize and wsize maxi=
ma of=20
> > 16384 bytes.
> >
> > RFC 1813:
> >> rtmax
> >> The maximum size in bytes of a READ request supported by the serve=
r. =20
> >> Any READ with a number greater than rtmax will result in a short r=
ead of=20
> >> rtmax bytes or less.
>=20
> My OS is 2.6.29.2, Debian etch, on a PPC system. I swear I got 32K
> [rw]size with kernels < 2.6.19, at least "mount" reported them as
> such. With recent kernels, "mount" and your analysis agree on just
> 16K. So, what can I do?

There is nothing the client can do as long as the server says it won't
accept NFS requests with read or write sizes > 16k. You therefore need
to fix the server.

Trond

