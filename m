From: "Fabiano Reis" <silos.reis@ig.com.br>
Subject: Re: linus 2.4.20 nfs performance problem
Date: Tue, 16 Mar 2004 13:53:55 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <04e301c40b77$44a56400$3f32a8c0@ds.ig.com.br>
References: <8147E1B07201DD41B6B9F0D31E07B3840164890B@srv-grp-s07.dev.atos.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3HrI-0000Me-MD
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:56:04 -0800
Received: from smtp-26.ig.com.br ([200.226.132.160])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1B3HrG-0004Al-Ik
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 08:56:02 -0800
To: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
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

how did you change it? is it simple like changing a #define on kernel header
files and recompiling it? I was thinking the patch for this is too complex.

----- Original Message ----- 
From: "Brasseur Valéry" <Valery.Brasseur@atosorigin.com>
To: "Fabiano Reis" <silos.reis@ig.com.br>
Cc: <nfs@lists.sourceforge.net>
Sent: Tuesday, March 16, 2004 1:31 PM
Subject: RE: [NFS] linus 2.4.20 nfs performance problem


for testing we have increase the limit from 256 to 1024 en recompile.

the probleme seems to be the same !

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net
> [mailto:nfs-admin@lists.sourceforge.net]On Behalf Of Fabiano Reis
> Sent: Tuesday, March 16, 2004 2:37 PM
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] linus 2.4.20 nfs performance problem
>
>
> looks like you are getting the maximum number of nfs operations by
> mountpoint. See nfs.sourceforge.net
>
> The maximum nfs operations by mountpoint for kernel < 2.5.47 is 256
>
> I´m getting the same problem with kernel 2.4.20. I ipgraded a
> nfs client to
> kernel 2.6 and I still getting the same problem. Maybe a
> solution is to
> upgrade the server and client to kernel 2.6 (I didnt tested it yet)
>
> -
> Fabiano
>
> ----- Original Message ----- 
> From: "Brasseur Valéry" <Valery.Brasseur@atosorigin.com>
> To: <Charles.Lever@netapp.com>
> Cc: <nfs@lists.sourceforge.net>
> Sent: Tuesday, March 16, 2004 8:35 AM
> Subject: [NFS] linus 2.4.20 nfs performance problem
>
>
> I have a config where LInux machines (bi Xeon 2.4Ghz 2Gb
> memory, kernel
> 2.4.20 + trond patch) are accessing a Netapp 810 (or 825)
>
> there is a lot of process (#400)
> when in load a lots of process are in D state, the filer are
> around 5000
> nfsops and the network is near 50 mbit/s for each machine
>
> the machine and the filer are connect by a switch, machines
> are at 100mb and
> filer is at 1Gb
>
> the cpu on the machines are near &à% and load average is near
> 100 or more
>
>
> I don't know where is the bottleneck...
>
> is somebody can help me ?
>
>
> thanks in advance
> valery
>
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id70&alloc_id638&op=ick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id70&alloc_id638&op=ick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
