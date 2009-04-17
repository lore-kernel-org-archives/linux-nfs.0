From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS issues with recent kernels [long]
Date: Fri, 17 Apr 2009 12:29:23 -0400
Message-ID: <B05C16C7-53B5-4E26-8239-956C600CF452@oracle.com>
References: <20090417102659.GC55096@fuchs>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Andr=E9_Berger?= <andre.berger@web.de>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090417102659.GC55096@fuchs>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Copying linux-nfs@vger.kernel.org, please follow up there.

On Apr 17, 2009, at 6:27 AM, Andr=E9 Berger wrote:

> I'm experiencing NFS [rw]size problems ever since kernel 2.6.18.8,
> which allowed for [rw]size=3D32768. Every kernel 2.16.19-29.6.25.20 (=
I
> tried every single subrevision) gave me only 8K mount results. Before
> I come to 2.6.29.1 and my current configuration, let me give you a
> short overview.

To summarize, you are running late model 2.6 kernels on a NAS =20
appliance, and your 2.4 clients are having trouble using large rsize =20
and wsize.

> My system was a Buffalo Linkstation ("LS1"), a PPC model,
>
>  <http://buffalo.nas-central.org/wiki/Category:LS1>
>
> with Debian etch and its NFS kernel server. The kernels < 2.6.20 were
> essentially compiled on a kernel.org or Debian etch basis, plus the
> patches from
>
>  <http://www.genbako.com/>
>
> while 2.6.20-2.6.25.20 were compiled from Sylver's
>
>  <http://linkstationwiki.svn.sourceforge.net/viewvc/linkstationwiki/k=
ernel_universal/=20
> >
>
> modified sources. Please find all .configs attached.
>
>
> The clients are Nokia and Sagem dboxII with kernel
>
>  Linux nokia 2.4.32-dbox2 #1 Do Aug 31 20:09:34 CEST 2006 ppc unknown
>
> with 10MBit Half Duplex Ethernet interfaces and Neutrino software, se=
e
>
>  <http://wiki.tuxbox.org/>
>
> for details.
>
>
> /etc/exports has never changed,
>
>  /mnt/media/incoming/movies =20
> 192.168.1.0=20
> /24(rw,async,no_subtree_check,all_squash,anonuid=3D1000,anongid=3D100=
0)
>
> The results vary, depending on the kernel. With 2.6.18, I used to get
>
>  192.168.1.8:/mnt/media/incoming/movies on /var/autofs/record type =20
> nfs (rw,v3,rsize=3D32768,wsize=3D32768,soft,udp,nolock,addr=3D192.168=
=2E1.8)
>
>  etc., for both TCP and UDP, on both dbox models.
>
> While I got only 8K with my LS1, my HG
>
>  <http://buffalo.nas-central.org/wiki/Category:HG>
>
> with 2.6.25.20 and 2.6.29.1 gives me 16K, but still not 32K. The
> numbers are related to the performance, 8K mounts make it impossible
> for me to use the LS as a VCR. 16K mounts seem to be better, but
> haven't been stress-tested yet here, as Cable TV bitrates vary.

Even with NFS/TCP ?  Oh, I see -- the clients are 10Mbit half-duplex.

> After an upgrade from Buffalo's bootloader in FLash ROM to uboot, I
> have been unable to boot non-flat device tree kernels like 2.6.18,
> and switched from the LS1 to the HG model in the troubleshooting
> process. As the latests kernels still don't reach 32K on that system
> either, I suspect a bug.

Any relevant messages in the kernel log on either the client or server?

You could try capturing a raw packet trace of the initial mount and a =20
few reads and write on the share.  The clients negotiate the rsize and =
=20
wsize settings with the server, and the packet dump would expose the =20
negotiated values.

On your clients, use "tcpdump -s 0 -w /tmp/raw host" followed by the =20
DNS name of your server.  Then attach the raw pcap files to e-mail (as =
=20
long as they are less than 100KB or so) and post them to linux-nfs@vger=
=2Ekernel.org=20
=2E

> For the sake of completeness, my router is a Linksys WRT54G
>
> with Tomato firmware
>
>  <http://www.polarcloud.com/tomato_123>
>
> and a MTU of 1492 throughout the network.
>
> If there is anything I can do to help troubleshooting, please let me
> know.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com