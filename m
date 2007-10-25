From: Andreas Schuldei <andreas@schuldei.org>
Subject: Re: nfs performance problem
Date: Thu, 25 Oct 2007 21:34:57 +0200
Message-ID: <20071025193457.GE4499@jakobus.spotify.net>
References: <20071025131029.GH8334@barnabas.schuldei.org>
	<7B68ECC3-7EBA-442F-9FFD-A0E3F2DCC61A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Il8U0-0002YG-IW
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 12:35:08 -0700
Received: from petrus.schuldei.org ([81.27.3.162] helo=barnabas.schuldei.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Il8U1-0001i1-Vu
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 12:35:12 -0700
In-Reply-To: <7B68ECC3-7EBA-442F-9FFD-A0E3F2DCC61A@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

* Chuck Lever (chuck.lever@oracle.com) [071025 20:25]:
> On Oct 25, 2007, at 9:10 AM, Andreas Schuldei wrote:
> >Hi!
> >
> >I need to tune a nfs server and client. on the server we have
> >several Tbyte of ~2Mbyte files and we need to transfer them read
> >only to the client. latency and throughput are crucial.

Because i have Tbytes of data but only a few Gbytes or RAM my
cache hits are rather unlikely. =


> >Right now i have only four disks in the server and i get 50Mbyte
> >out of each of them, simultaniously, for real world loads (random
> >reads across the disk, trying to minimizing the seeks by reading
> >the files in one go with
> >
> >for i in a b h i ; do ( find /var/disks/sd$i -type f | xargs -I=B0 dd if=
=3D=B0 bs=3D2M of=3D/dev/null status=3Dnoxfer =

> >2>/dev/null & ) ; done
> >
> >so with this (4*50 Mbyte/s) i should be able to saturate both
> >network cards.

note that this is my server's disk io performance.

> With a single client, you should not expect to get any better performance=
 than by running the web service on the NFS =

> server.  The advantage of using NFS under a web service is that you can t=
ransparently scale horizontally.  When you add =

> a second or third web server that serves the same file set, you will see =
an effective increase in the size of the data =

> cache between your NFS server's disks and the web servers.

Not with terabyte of data and a distributed access pattern.
Certainly i will have some cache hits but not enough to be able
to serv considerable amounts out of RAM.


> But don't expect to get better data throughput over NFS than you see on y=
our local NFS server. =


That is exactly the point. on my server i get 4*50Mbytes =3D
200Mbyte/s out of the disks (with the above FOR loop around the
find and dd) and when i export on the same server the disks to an
nfs client i all of a sudden loose ~75% of the performance.

> If anything, the 10s =

> latency you see when the web server is on the same system with the disks =
is indicative of local file system =

> configuration issues.

how can i measure the latency on the local machine? i would be
very interested in seeing how it behaves latency wise.

> >on the server i start 128 nfs servers (RPCNFSDCOUNT=3D128) and export
> >the disks like this:
> >
> >/usr/sbin/exportfs -v
> >/var/disks/sda <world>(ro,async,wdelay,root_squash,no_subtree_check,anon=
uid=3D65534,anongid=3D65534)
> >/var/disks/sdb <world>(ro,async,wdelay,root_squash,no_subtree_check,anon=
uid=3D65534,anongid=3D65534)
> >/var/disks/sdh <world>(ro,async,wdelay,root_squash,no_subtree_check,anon=
uid=3D65534,anongid=3D65534)
> >/var/disks/sdi <world>(ro,async,wdelay,root_squash,no_subtree_check,anon=
uid=3D65534,anongid=3D65534)
> =

> On the server, mounting the web data file systems with "noatime" may help=
 reduce the number of seeks on the disks.

yes, we do that already.

> >on the client i mount them like this:
> >
> >lotta:/var/disks/sda on /var/disks/sda type nfs (ro,hard,intr,proto=3Dtc=
p,rsize=3D32k,addr=3D217.213.5.44)
> >lotta:/var/disks/sdb on /var/disks/sdb type nfs (ro,hard,intr,proto=3Dtc=
p,rsize=3D32k,addr=3D217.213.5.44)
> >lotta:/var/disks/sdh on /var/disks/sdh type nfs (ro,hard,intr,proto=3Dtc=
p,rsize=3D32k,addr=3D217.213.5.44)
> >lotta:/var/disks/sdi on /var/disks/sdi type nfs (ro,hard,intr,proto=3Dtc=
p,rsize=3D32k,addr=3D217.213.5.44)
> =

> There are some client-side mount options that might also help.  Using "no=
cto" and "actimeo=3D7200" could reduce =

> synchonous NFS protocol overhead.  I also notice a significant amount of =
readdirplus traffic.  Readdirplus requests are =

> fairly heavyweight, and in this scenario may be unneeded overhead.  Your =
client might support the recently added =

> "nordirplus" mount option, which could be helpful.
> =

> I wonder if "rsize=3D32k" is supported - you might want "rsize=3D32768" i=
nstead.

i think that gave an effect. now i am in the 90-100Mbyte/s
ballpark and might hit the one-nic (1gbit) bottleneck.

> Or better, let the client and server =

> negotiate the maximum that each supports automatically by leaving this op=
tion off.  You can check what options are in =

> effect on each NFS mount point by looking in /proc/self/mountstats on the=
 client.

there it says now, after i specified rsize=3D2097152:
        opts:   rw,vers=3D3,rsize=3D1048576,wsize=3D1048576,acregmin=3D3,ac=
regmax=3D60,acdirmin=3D30,acdirmax=3D60,hard,intr,nolock,proto=3Dtcp,timeo=
=3D600,retrans=3D2,sec=3Dsys

i am surprised that it did not protest when it could not parse
the "k". note that it it only took 1M chunks. how come?

> Enabling jumbo frames between your NFS server and client will help.  Depe=
nding on your NIC, though, it may introduce =

> some instability (driver and hardware mileage may vary).

i will test that and bonding two nicks.

> Insufficient read-ahead on your server may be an issue here.  Read traffi=
c from the client often arrives at the server =

> out of order, preventing the server from cleanly detecting sequential rea=
ds.  I believe there was a recent change to =

> the NFS server that addresses this issue.

when did that go in? do i need to activate that somehow?

how can i measure the latency on a loaded server? both locally
and over nfs?

/andreas

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
