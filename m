From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Poor Fedora Core 1's NFS performance and how to tune it?
Date: Sat, 17 Apr 2004 07:30:55 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07C15@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "ops" <ops@alexa.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BEqqe-0000tm-1X
	for nfs@lists.sourceforge.net; Sat, 17 Apr 2004 07:31:12 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BEqqd-0001yk-S7
	for nfs@lists.sourceforge.net; Sat, 17 Apr 2004 07:31:11 -0700
To: "Guolin Cheng" <guolin@alexa.com>
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

it is not clear from your description of the problem whether
you see this problem only when using the FC1 NFS server.  that
is, RH8 | FC1 clients are always fast against an RH8 server,
but both are always slow against an FC1 server...?

did the "sync" export option default change between RH8 and FC1?
that would be an nfs-utils change, so it would have nothing to
do with the kernel version or whether TCP was in use.

> -----Original Message-----
> From: Guolin Cheng [mailto:guolin@alexa.com]=20
> Sent: Friday, April 16, 2004 6:53 PM
> To: nfs@lists.sourceforge.net
> Cc: ops
> Subject: [NFS] Poor Fedora Core 1's NFS performance and how=20
> to tune it?
>=20
>=20
> Hi,
>=20
>  We installed about tens of Fedora Core 1 machines, But then=20
> found that
> the FC1 NFS speed is greatly slow down contrasted with our previous
> Redhat 8.0.
> Our FC1's nfs speed is now at 6MB/s, while original Redhat 8.0's speed
> is at 10MB/s. For both operation systems I did no special NFS tunings.
>=20
> Our Original environment RH8 environment is:  Redhat 8.0,=20
> 2.4.20 vanilla
> kernel without "nfs over tcp" support.
>=20
> Our current environment is: Fedora Core 1, 2.4.25 vanilla kernel, with
> "nfs over tcp" kernel support enabled.
>=20
> But it seems that the nfs performance has no directly=20
> relationship with
> "nfs over tcp" in kernel configuration. The reason is:=20
>=20
> I use both RH8|FC1 clients to connect to FC1 nfs server,=20
> connections set
> to either "nfs over udp" or "nfs over tcp", the speed is=20
> about the same,
> ranged from 6.09MB/s to 6.30MB/s.
>=20
> But from original RH8 nfs clients to RH8 nfs servers, the speed is at
> 10MB-11MB/s, since I compiled no "nfs over tcp" support for=20
> RH8 kernel,
> the nfs connection is based on UDP traffic only.
>=20
> Personally I prefer "nfs over tcp" feature enabled. Since tcp=20
> traffic is
> more reliable and bring less trouble to Ops, even it is a little less
> efficient.=20
>=20
> I tried to increase the NFS read/write size from 1024/1024, to
> 4096/4096, to 8192/8192, but that makes almost no difference at all.
>=20
> Any suggestions/opinions on why FC1's nfs performance is=20
> downgraded? Or
> I need to adjust any other parameters?=20
>=20
> Thanks.
> --Guolin Cheng
>=20
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id=1470&alloc_id638&op=3Dick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
