From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: ANNOUNCE: nfs-utils 1.0.7-pre2
Date: Fri, 10 Dec 2004 14:20:06 +0100
Message-ID: <200412101420.06172.bernd-schubert@web.de>
References: <16825.223.924965.582375@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cckgw-00064N-8R
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 05:20:14 -0800
Received: from smtp06.web.de ([217.72.192.224])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1Cckgv-0007Pw-41
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 05:20:14 -0800
Received: from [80.140.3.170] (helo=bathl.lan.fli4l)
	by smtp06.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.103 #184)
	id 1Cckgn-000150-00
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 14:20:05 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <16825.223.924965.582375@cse.unsw.edu.au>
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

On Friday 10 December 2004 02:50, Neil Brown wrote:
> I have made available a second pre-release of nfs-utils 1.0.7.
>
> It can be downloaded from
>   http://sourceforge.net/project/showfiles.php?group_id=3D14
> or
>   http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/
>
> This release adds some statd fixes and a couple of other small bug fixes,
> and also gets ./configure to complain if libnfsidmap or libevent aren't
> installed (unless --disable-nfsv4 is selected).
> README also says where to get these libraries from.

Well, it still complains with --disable-nfsv4:

svcgssd_proc.c:47:22: nfsidmap.h: No such file or directory
make[4]: *** [dep] Error 1
make[3]: *** [dep] Error 2
make[2]: *** [dep] Error 2

Should the configure script assume '--disable-gss' when --disable-nfsv4 is=
=20
given?=20

>
> I still hope to put this out as a final 1.0.7 before Christmas.
> Having lots of people say "Yes, I've tried it, and it works OK" would
> make a great Christmas present :-)
>

Well, with --disable-nfsv4 --disable-gss and without '--enable-secure-statd=
'=20
the statd seems to work fine. As I posted a very long time ago, we are seei=
ng=20
messages like this

lockd: cannot monitor 129.206.21.200
lockd: failed to monitor 129.206.21.200
statd: server localhost not responding, timed out
nsm_mon_unmon: rpc failed, status=3D-5
lockd: cannot monitor 129.206.21.200
lockd: failed to monitor 129.206.21.200


very often if '--enable-secure-statd' is enabled. This also causes much=20
trouble to other services as portmap, ssh, nis, cron, etc. and makes them=20
also crash (not so good as we can't reboot the systems).
Unfortunately this also happens randomly to one/some of our clients rather=
=20
often since we switched to a new server in summer, don't know the reasons=20
yet.
I will now try to enable secure-statd, compiling with debug options and hop=
e=20
the statd core files will help to understand the problem. Though, maybe tho=
se=20
problems are already fixed?


Cheers,
 Bernd


=2D-=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
