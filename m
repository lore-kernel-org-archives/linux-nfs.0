From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: kernel nlockmgr not registred with port mapper
Date: Fri, 13 Aug 2004 12:14:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092413690.5046.20.camel@lade.trondhjem.org>
References: <411C91BA.10506@naturalsciences.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bvehh-0004K5-PH
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 09:14:53 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bvehh-0003PV-E0
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 09:14:53 -0700
To: Paul Libert <Paul.Libert@naturalsciences.be>
In-Reply-To: <411C91BA.10506@naturalsciences.be>
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

P=E5 fr , 13/08/2004 klokka 06:02, skreiv Paul Libert:
> Dear List,
>=20
> Solution to this problem should be easy but I'm to blind to find out so=20
>    ...
>=20
> I'm having problem with to acquire locks on file over a nfs mounted=20
> filesystem.
>=20
> Client system is a Debian Linux with 2.4.25 Debian packaged kernel
> Server system is a Debian Linux with 2.4.24 Debian packaged kernel or=20
> 2.6.6 Debian packaged kernel.
>=20
> After looking on the system, it appears that a 'rpcinfo -p' on both=20
> server shows no nlockmgr :
>=20
> Server 1 :
>     program vers proto   port
>      100000    2   tcp    111  portmapper
>      100000    2   udp    111  portmapper
>      100024    1   udp    882  status
>      100024    1   tcp    885  status
>      100003    2   udp   2049  nfs
>      100003    2   tcp   2049  nfs
>      100005    1   udp    897  mountd
>      100005    2   udp    897  mountd
>      100005    1   tcp    900  mountd
>      100005    2   tcp    900  mountd
> Server 2 :
>     program vers proto   port
>      100000    2   tcp    111  portmapper
>      100000    2   udp    111  portmapper
>      100011    1   udp    795  rquotad
>      100011    2   udp    795  rquotad
>      100011    1   tcp    798  rquotad
>      100011    2   tcp    798  rquotad
>      100024    1   udp    846  status
>      100024    1   tcp    849  status
>      100003    2   udp   2049  nfs
>      100003    2   tcp   2049  nfs
>      100005    1   udp    953  mountd
>      100005    2   udp    953  mountd
>      100005    1   tcp    956  mountd
>      100005    2   tcp    956  mountd
>      390113    1   tcp   7937
>=20
<snip>
> It must be obvious but I keep missing it ...

Looks to me as if you are using the user space NFS server. That never
had any support for the NLM locking protocol. In fact IIRC the addition
of locking support was one of the main motivations at the time for
writing the kernel NFS server (correct me if I'm wrong there Olaf).

Cheers,
  Trond


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
