From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Reading 64k blocks at a time
Date: Wed, 28 Jun 2006 15:23:37 -0400
Message-ID: <1151522618.29569.38.camel@lade.trondhjem.org>
References: <20060628143949.1D55.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, f.soto@terra.com.br
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fvfdm-0006O8-EY
	for nfs@lists.sourceforge.net; Wed, 28 Jun 2006 12:23:58 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fvfdh-0006ce-3g
	for nfs@lists.sourceforge.net; Wed, 28 Jun 2006 12:23:58 -0700
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20060628143949.1D55.BRANDEN@terra.com.br>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2006-06-28 at 14:47 -0300, Filipe Brandenburger wrote:
> Hello,
> 
> I'm having a performance problem on NFS. My client machines are RHEL4
> with kernel 2.6.9-34.ELsmp, I'm mounting NFS from EMC and Netapp
> storages, the mount options are the following:
> 
> rw,vers=3,proto=udp,intr,nolock,noexec,rsize=8192,wsize=8192
> 
> The problem I seem to have is that I try to make a small read (of 1 to 2
> kbytes) but the kernel seems to be reading almost 64kb from the file
> (supposing that the file actually has this amount of bytes). This seems
> to be some kind of read-ahead.
> 
> The problem is that when I try to fetch the first 1kb of several big
> files, it gets really slow... I wonder, is there some way to change this
> behaviour or tune it on the O.S. so that I don't have to read that much
> to get that little information?

'man posix_fadvise()'

Cheers,
  Trond

> Following is the data showing the behaviour.
> 
> Thanks in advance,
> Filipe Brandenburger
> 
> 
> 
> strace:
> 
>      0.000075 open("/nfs/mail3d01/t/e/s/t/e/p/r/o/x/y/teste.proxy/Maildir/cur/1150856490.214204.16718,152143.morondava.hst.terra.com.br:2,_2562", O_RDONLY) = 3
>      1.574855 fstat64(1, {st_mode=S_IFREG|0644, st_size=3048, ...}) = 0
>      0.000129 mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f58000
>      0.000074 fstat64(3, {st_mode=S_IFREG|0644, st_size=115423, ...}) = 0
>      0.000109 mmap2(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f56000
>      0.000076 read(3, "Return-Path: "..., 8192) = 8192
>      0.011101 close(3)                  = 0
>      0.000053 munmap(0xb7f56000, 8192)  = 0
> 
> 
> tcpdump:
> 
> 13:50:18.045641 IP aldabra.vpn.terra.com.br.4211277024 > server3d.vpn.terra.com.br.nfs: 152 lookup fh 0,22/1 "cur"
> 13:50:18.053559 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.4211277024: reply ok 240 lookup fh 0,22/1
> 13:50:18.053600 IP aldabra.vpn.terra.com.br.4228054240 > server3d.vpn.terra.com.br.nfs: 148 access fh 0,22/1 001f
> 13:50:18.053758 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.4228054240: reply ok 120 access c 001f
> 13:50:18.053813 IP aldabra.vpn.terra.com.br.4244831456 > server3d.vpn.terra.com.br.nfs: 216 lookup fh 0,22/1 "1150856490.214204.16718,152143.morondava.hst.terra.com.br:2,_2562"
> 13:50:19.314478 IP aldabra.vpn.terra.com.br.4244831456 > server3d.vpn.terra.com.br.nfs: 216 lookup fh 0,22/1 "1150856490.214204.16718,152143.morondava.hst.terra.com.br:2,_2562"
> 13:50:19.472875 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.4244831456: reply ok 240 lookup fh 0,22/1
> 13:50:19.472940 IP aldabra.vpn.terra.com.br.4261608672 > server3d.vpn.terra.com.br.nfs: 148 access fh 0,22/1 002d
> 13:50:19.473203 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.4261608672: reply ok 120 access c 002d
> 13:50:19.473788 IP aldabra.vpn.terra.com.br.4278385888 > server3d.vpn.terra.com.br.nfs: 156 read fh 0,22/1 8192 bytes @ 0x0
> 13:50:19.473813 IP aldabra.vpn.terra.com.br.261344 > server3d.vpn.terra.com.br.nfs: 156 read fh 0,22/1 8192 bytes @ 0x2000
> 13:50:19.483936 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.4278385888: reply ok 1472 read
> 13:50:19.484054 IP aldabra.vpn.terra.com.br.17038560 > server3d.vpn.terra.com.br.nfs: 156 read fh 0,22/1 8192 bytes @ 0x4000
> 13:50:19.484081 IP aldabra.vpn.terra.com.br.33815776 > server3d.vpn.terra.com.br.nfs: 156 read fh 0,22/1 8192 bytes @ 0x6000
> 13:50:19.487413 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.261344: reply ok 1472 read
> 13:50:19.487534 IP aldabra.vpn.terra.com.br.50592992 > server3d.vpn.terra.com.br.nfs: 156 read fh 0,22/1 8192 bytes @ 0x8000
> 13:50:19.498457 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.50592992: reply ok 1472 read
> 13:50:19.498567 IP aldabra.vpn.terra.com.br.67370208 > server3d.vpn.terra.com.br.nfs: 156 read fh 0,22/1 8192 bytes @ 0xa000
> 13:50:19.498590 IP aldabra.vpn.terra.com.br.84147424 > server3d.vpn.terra.com.br.nfs: 156 read fh 0,22/1 8192 bytes @ 0xc000
> 13:50:19.499676 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.17038560: reply ok 1472 read
> 13:50:19.499821 IP aldabra.vpn.terra.com.br.100924640 > server3d.vpn.terra.com.br.nfs: 156 read fh 0,22/1 4096 bytes @ 0xe000
> 13:50:19.507262 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.67370208: reply ok 1472 read
> 13:50:19.508275 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.100924640: reply ok 1472 read
> 13:50:19.522459 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.33815776: reply ok 1472 read
> 13:50:19.530880 IP server3d.vpn.terra.com.br.nfs > aldabra.vpn.terra.com.br.84147424: reply ok 1472 read
> 
> 
> 
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
