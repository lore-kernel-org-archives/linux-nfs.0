From: "Guolin Cheng" <guolin@alexa.com>
Subject: RE: [NFS] Poor Fedora Core 1's NFS performance and how to tune it?
Date: Sat, 17 Apr 2004 22:46:12 -0700
Sender: fedora-list-bounces@redhat.com
Message-ID: <41089CB27BD8D24E8385C8003EDAF7AB08485C@karl.alexa.com>
Reply-To: For users of Fedora Core releases <fedora-list@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: fedora-list@redhat.com, nfs@lists.sourceforge.net
Return-path: <fedora-list-bounces@redhat.com>
To: "Lever, Charles" <Charles.Lever@netapp.com>
List-Unsubscribe: <http://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=unsubscribe>
List-Archive: </archives/fedora-list>
List-Post: <mailto:fedora-list@redhat.com>
List-Help: <mailto:fedora-list-request@redhat.com?subject=help>
List-Subscribe: <http://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=subscribe>
Errors-To: fedora-list-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

Hi, Lever,

 Thanks for you reply. But I just figure out it is a less than obvious
problem... The real problems, FC1 nfs server has a Broadcom gigabit
card, which driver, tg3, is too problematic. So that tg3 driver, either
in the default FC1 kernel, or vanilla 2.4.25 kernel, both bring down the
nfs speed. After I download the bcm5700 driver from Broadcom company
website and patched it into my 2.4.25 vanilla kernel, the nfs speed
jumps to 10.5MB/s! same as other FC1 nfs clients|servers.

Because I installed|tested Broadcom gigabit FC1 hosts at first, so I
easily wrongly blamed FC1 nfs. I feel too shamed of myself now. :(   But
finally I figured out the real problem, then I'm a little proud of
myself again. :)

Hope everyone will notice the FC1 tg3 driver's problem and fix it with
bcm5700 driver. =20

--Guolin Cheng


-----Original Message-----
From: Lever, Charles [mailto:Charles.Lever@netapp.com]=20
Sent: Saturday, April 17, 2004 7:31 AM
To: Guolin Cheng
Cc: ops; nfs@lists.sourceforge.net
Subject: RE: [NFS] Poor Fedora Core 1's NFS performance and how to tune
it?

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



--=20
fedora-list mailing list
fedora-list@redhat.com
To unsubscribe: http://www.redhat.com/mailman/listinfo/fedora-list
