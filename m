From: AK <amithl_prem@yahoo.com>
Subject: POSIX I/O on NFS with noac option
Date: Thu, 12 Apr 2007 09:59:05 -0700 (PDT)
Message-ID: <949021.41130.qm@web56603.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1864236004=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc2dg-0006Df-Kp
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 09:59:17 -0700
Received: from web56603.mail.re3.yahoo.com ([66.196.97.47])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Hc2dh-0000rL-Ob
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 09:59:19 -0700
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

--===============1864236004==
Content-Type: multipart/alternative; boundary="0-539082517-1176397145=:41130"
Content-Transfer-Encoding: 7bit

--0-539082517-1176397145=:41130
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Trying to get this POSIX I/O code to work on our machines.

Running it from a NFS v3 mounted scratch sapce, with 'noac' option: no ca=
ching attribute option.
It fails to run: gives me err=3D -1 and errno =3D 5

Although this works without error on my NFS v3 mounted home
directories. Which are mounted from the head node of our cluster(Linux ba=
sed head node and compute nodes).
 =20
Where as the scratch sapce is mounted of our storage server(Solaris). Any=
 thoughts on issues related to Solars hosting NFS server and Linux nfs cl=
ient ..with noac options ???

Any idea ? Appreciate any feedback
~thanks - ak

#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

main()
{
   struct flock lock;
   int fd, err;

   lock.l_type =3D F_WRLCK;
   lock.l_start =3D 0;
   lock.l_whence =3D SEEK_SET;
   lock.l_len =3D 100;

   fd =3D open("test", O_RDWR | O_CREAT, 0644);

   err =3D fcntl(fd, F_SETLKW, &lock);

   printf("err =3D %d, errno =3D %d\n", err, errno);
   close(fd);
}


      =20
---------------------------------
Need Mail bonding?
Go to the Yahoo! Mail Q&A for great tips from Yahoo! Answers users.
--0-539082517-1176397145=:41130
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

<div><SPAN style=3D"FONT-SIZE: larger"><FONT size=3D4>Trying to get this =
POSIX I/O code to work on our machines.<BR><BR>Running it from a NFS v3 m=
ounted scratch sapce, with 'noac' option: no caching attribute option.<BR=
>It fails to run: gives me err=3D -1 and errno =3D 5<BR><BR>Although this=
 works without error on my NFS v3 mounted home<BR>directories. Which are =
mounted from the head node of our cluster(Linux based head node and compu=
te nodes).</FONT></SPAN></div>  <div><SPAN style=3D"FONT-SIZE: larger"><F=
ONT size=3D4><BR>Where as the scratch sapce is mounted of our storage ser=
ver(Solaris). Any thoughts on issues related to Solars hosting NFS server=
 and Linux nfs client ..with noac options ???<BR><BR>Any idea ? Appreciat=
e any feedback<BR>~thanks - ak<BR><BR>#include &lt;fcntl.h&gt;<BR>#includ=
e &lt;errno.h&gt;<BR>#include &lt;unistd.h&gt;<BR><BR>main()<BR>{<BR>&nbs=
p; &nbsp;struct flock lock;<BR>&nbsp; &nbsp;int fd, err;<BR><BR>&nbsp; &n=
bsp;lock.l_type =3D F_WRLCK;<BR>&nbsp;
 &nbsp;lock.l_start =3D 0;<BR>&nbsp; &nbsp;lock.l_whence =3D SEEK_SET;<BR=
>&nbsp; &nbsp;lock.l_len =3D 100;<BR><BR>&nbsp; &nbsp;fd =3D open("test",=
 O_RDWR | O_CREAT, 0644);<BR><BR>&nbsp; &nbsp;err =3D fcntl(fd, F_SETLKW,=
 &amp;lock);<BR><BR>&nbsp; &nbsp;printf("err =3D %d, errno =3D %d\n", err=
, errno);<BR>&nbsp; &nbsp;close(fd);<BR>}<BR></div></FONT></SPAN><p>&#32;
      <hr size=3D1>Need Mail bonding?<br>Go to the <a href=3D"http://answ=
ers.yahoo.com/dir/index;_ylc=3DX3oDMTFvbGNhMGE3BF9TAzM5NjU0NTEwOARfcwMzOT=
Y1NDUxMDMEc2VjA21haWxfdGFnbGluZQRzbGsDbWFpbF90YWcx?link=3Dask&sid=3D39654=
6091">Yahoo! Mail Q&A</a> for <a href=3D"http://answers.yahoo.com/dir/ind=
ex;_ylc=3DX3oDMTFvbGNhMGE3BF9TAzM5NjU0NTEwOARfcwMzOTY1NDUxMDMEc2VjA21haWx=
fdGFnbGluZQRzbGsDbWFpbF90YWcx?link=3Dask&sid=3D396546091">great tips from=
 Yahoo! Answers</a> users.
--0-539082517-1176397145=:41130--


--===============1864236004==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1864236004==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1864236004==--
