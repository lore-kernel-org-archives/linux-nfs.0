From: Chris Penney <cpenney@gmail.com>
Subject: Re: Performance Difference Between Linux NFS Server and Netapp
Date: Thu, 14 Jul 2005 15:50:09 -0400
Message-ID: <111aefd050714125064cb549e@mail.gmail.com>
References: <42D2F8F9.4010304@plasmabat.com>
	 <Pine.SOC.4.61.0507141312090.9294@tea.blinkenlights.nl>
	 <42D6AD28.3030204@plasmabat.com>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_3359_12778863.1121370609664"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt9jd-0007tT-G7
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 12:51:05 -0700
Received: from wproxy.gmail.com ([64.233.184.198])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Dt9jd-0001kD-0n
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 12:51:05 -0700
Received: by wproxy.gmail.com with SMTP id 70so497920wra
        for <nfs@lists.sourceforge.net>; Thu, 14 Jul 2005 12:50:59 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <42D6AD28.3030204@plasmabat.com>
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

------=_Part_3359_12778863.1121370609664
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 7/14/05, Hugh Caley <hcaley@plasmabat.com> wrote:=20
>=20
> A valid point, of course, but I don't think I'm actually expecting a
> single NFSd to act like an expensive Netapp. I do think that wondering
> why the Netapp is twice as fast for a sequential write is a valid
> question, even if the OS and NFS server subsystem are free. I was kind
> of hoping someone would just say "you're getting what you should expect
> to get" or "wow, that's slow, try this and this and this".

 You referenced that you were getting 300 megabits (or 37MB/s). I have=20
several SLES 9 nfs servers (using self compiled 2.6.11.5
<http://2.6.11.5>kernel) running on IBM x345 hardware (dual cpu pentum
4, 2gb ram, dual
qlogic hbas) connected to a single LSI storage array that presents four lun=
s=20
(two from controller A and two from B). Each lun is 1TB and made from=20
hardware raid 8+1. Luns are merged together using device mapper.
 It's not uncommon with my setup to get a sustained write speed of 75MB/s o=
n=20
one of our SLES 9 compute systems (AMD Opterons) when doing a sequential=20
write of an 8GB file. With two systems writing at the same time I get=20
aggregate bandwidth better than 75MB/s (can't recall what it is).
 I use tcp/nfs3 and for write testing I use 'iozone -c -e -s 8192m -i 0'. I=
=20
use 128 nfsds, export with 'rw,sync,no_subtree_check,no_root_squash' and ad=
d=20
the following to sysctl.conf:
 net.core.rmem_default =3D 262144
net.core.wmem_default =3D 262144
net.core.rmem_max =3D 8388608
net.core.wmem_max =3D 8388608
net.ipv4.tcp_rmem =3D 4096 87380 8388608
net.ipv4.tcp_wmem =3D 4096 65536 8388608
net.ipv4.tcp_mem =3D 8388608 8388608 8388608
 On nfs clients (Sun, Linux, IRIX) I use the mount options:=20
nosuid,rw,bg,hard,intr,vers=3D3,proto=3Dtcp,rsize=3D32768,wsize=3D32768. On=
 AIX I=20
use the same options, but also add the critical 'combehind' (without it=20
writes of large files [ie. close to the size of physical mem] is just=20
horrid).=20
  Chris

------=_Part_3359_12778863.1121370609664
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<div><span class=3D"gmail_quote">On 7/14/05, <b class=3D"gmail_sendername">=
Hugh Caley</b> &lt;<a href=3D"mailto:hcaley@plasmabat.com">hcaley@plasmabat=
.com</a>&gt; wrote:</span>=20
<blockquote class=3D"gmail_quote" style=3D"PADDING-LEFT: 1ex; MARGIN: 0px 0=
px 0px 0.8ex; BORDER-LEFT: #ccc 1px solid">A valid point, of course, but I =
don't think I'm actually expecting a<br>single NFSd to act like an expensiv=
e Netapp.&nbsp;&nbsp;I do think that wondering
<br>why the Netapp is twice as fast for a sequential write is a valid<br>qu=
estion, even if the OS and NFS server subsystem are free.&nbsp;&nbsp;I was =
kind<br>of hoping someone would just say &quot;you're getting what you shou=
ld expect
<br>to get&quot; or &quot;wow, that's slow, try this and this and this&quot=
;.</blockquote>
<div>&nbsp;</div>
<div>You referenced that you were getting 300 megabits (or 37MB/s).&nbsp; I=
 have several SLES 9 nfs servers (using self compiled <a href=3D"http://2.6=
.11.5">2.6.11.5</a> kernel) running on IBM x345 hardware (dual cpu pentum 4=
, 2gb ram, dual qlogic hbas) connected to a single LSI storage array that p=
resents four luns (two from controller A and two from B).&nbsp; Each lun is=
 1TB and made from hardware raid 8+1.&nbsp; Luns are merged together using =
device mapper.
</div>
<div>&nbsp;</div>
<div>It's not uncommon with my setup to get a sustained write speed of 75MB=
/s on one of our SLES 9 compute systems (AMD Opterons) when doing a sequent=
ial write of an 8GB file.&nbsp; With two systems writing at the same time I=
 get aggregate bandwidth better than 75MB/s (can't recall what it is).
</div>
<div>&nbsp;</div>
<div>I use tcp/nfs3 and for write testing I use 'iozone -c -e -s 8192m -i 0=
'.&nbsp; I use 128 nfsds, export with 'rw,sync,no_subtree_check,no_root_squ=
ash'&nbsp;and add the following to sysctl.conf:</div>
<div>&nbsp;</div>
<div>net.core.rmem_default =3D 262144<br>net.core.wmem_default =3D 262144<b=
r>net.core.rmem_max =3D 8388608<br>net.core.wmem_max =3D 8388608<br>net.ipv=
4.tcp_rmem =3D 4096 87380 8388608<br>net.ipv4.tcp_wmem =3D 4096 65536 83886=
08<br>net.ipv4.tcp_mem
 =3D 8388608 8388608 8388608<br>&nbsp;</div>
<div>On nfs clients (Sun, Linux, IRIX) I use the mount options: nosuid,rw,b=
g,hard,intr,vers=3D3,proto=3Dtcp,rsize=3D32768,wsize=3D32768.&nbsp; On AIX =
I use the same options, but also add the critical 'combehind' (without it w=
rites of large files [ie. close to the size of physical mem] is just horrid=
).&nbsp;
</div>
<div>&nbsp;</div>
<div>&nbsp;&nbsp; Chris</div>
<div>&nbsp;</div></div>

------=_Part_3359_12778863.1121370609664--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
