From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: nfs performance problem
Date: Thu, 7 Nov 2002 18:32:06 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021107183206.P23227@vestdata.no>
References: <CDC5FB5947D3D3119E2D00A0C9B6AF2D06777678@es06-hou.bmc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189qVx-0004qv-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Nov 2002 09:32:22 -0800
To: "Baker, Byran" <Byran_Baker@bmc.com>
In-Reply-To: <CDC5FB5947D3D3119E2D00A0C9B6AF2D06777678@es06-hou.bmc.com>; from Byran_Baker@bmc.com on Thu, Nov 07, 2002 at 09:19:44AM -0600
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Nov 07, 2002 at 09:19:44AM -0600, Baker, Byran wrote:
> We have a couple of NFS servers with 3ware cards.  One is a 3ware 7850 =
(8
> Maxtor 160GB - 5400RPM) and one is a 3ware 7500-12, both configured wit=
h
> RAID 5 + Hot Spare.  I have all the latest NFS patches applied.  If I a=
ccess
> an NFS mounted directory on one of these systems and copy a bunch of li=
ttle
> files (1-2KB), I get 150-250 tps.  If I access larger files (90% > 1MB =
each)
> I will normally see 25-60MB/s transfer with 500-700 tps, with peaks of =
over
> 1000 tps - A good indication that disk seek is to blame for the problem=
 with
> the small files.


Just to clarify here.

I bet when you transfer 1-2KB files you are able to transfer 150-250
files pr second, right?=20

When you transfer larger files the files pr second rate goes down, but
the tps-rate increases because each file is split into multiple scsi
requests.=20


And yes, I would agree with your conclution that disk seek is to blame.

Are those numbers for reads or writes? I would expect to see the same
tendency, but with stronger effect, for writes than reads.



--=20
Ragnar Kj=F8rstad
Big Storage


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
