From: fantoosh bantoosh <fantoosh@hotmail.com>
Subject: How to secure network link in NFSv4 ?
Date: Thu, 9 Aug 2007 20:06:48 +0000
Message-ID: <BAY128-W20C2F1F31DF110063A2E23C9E00@phx.gbl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0559158263=="
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJEHS-00066e-2G
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 13:06:50 -0700
Received: from bay0-omc3-s22.bay0.hotmail.com ([65.54.246.222])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IJEHV-0006U9-Tb
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 13:06:54 -0700
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

--===============0559158263==
Content-Type: multipart/alternative;
	boundary="_a2d22b76-0790-483a-aaa5-2cc84d3ddfdd_"

--_a2d22b76-0790-483a-aaa5-2cc84d3ddfdd_
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable

Dear All,I am interested in doing some performance evaluation of NFSv4. I w=
ant to=0A=
evaluate the overhead on the filesystem operations when we enable=0A=
integrity and encryption of NFS traffic. This will give me an idea whether =
to use secure channel with our NFS servers or  not. I have machines with li=
nux 2.6.13-15.- My first question is: for the sake of evaluation, what woul=
d be the easiest way (requiring least setup) to enable network security for=
 NFS?I probably have two options: a) tunnel the NFS traffic through SSH as =
explained in http://www.vanemery.com/Linux/NFSv4/NFSv4-no-rpcsec.html#sshtu=
nb) setup kerberos and use sec=3Dkrb5p mount optionIs there any other way I=
 can easily setup a secure channel between NFS client and a server?- My sec=
ond question is: of the above two which one is the best option that will re=
present the overhead of NFS with secure channel? I would imagine that the f=
irst option (with SSH port forwarding) will incur more overhead than the se=
cond one due to memory copy and messaging between the NFS and SSH process. =
Can anyone please confirm this and suggest and quick way to setup NFS with =
secure channel in way that will correctly represent the NFS overhead? Point=
ers to setup examples, if any, will be very helpful.Thanks.Regards,Fantoosh
_________________________________________________________________
Find a local pizza place, movie theater, and more=85.then map the best rout=
e!
http://maps.live.com/default.aspx?v=3D2&ss=3Dyp.bars~yp.pizza~yp.movie%20th=
eater&cp=3D42.358996~-71.056691&style=3Dr&lvl=3D13&tilt=3D-90&dir=3D0&alt=
=3D-1000&scene=3D950607&encType=3D1&FORM=3DMGAC01=

--_a2d22b76-0790-483a-aaa5-2cc84d3ddfdd_
Content-Type: text/html; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<style>
P
{
margin:0px;
padding:0px
}
body
{
FONT-SIZE: 10pt;
FONT-FAMILY:Tahoma
}
</style>
</head>
<body><div style=3D"text-align: left;"><br>Dear All,<br><br>I am interested=
 in doing some performance evaluation of NFSv4. I want to=0A=
evaluate the overhead on the filesystem operations when we enable=0A=
integrity and encryption of NFS traffic. This will give me an idea whether =
to use secure channel with our NFS servers or&nbsp; not. I have machines wi=
th linux 2.6.13-15.<br><br>- My first question is: for the sake of evaluati=
on, what would be the easiest way (requiring least setup) to enable network=
 security for NFS?<br>I probably have two options: <br>a) tunnel the NFS tr=
affic through SSH as explained in http://www.vanemery.com/Linux/NFSv4/NFSv4=
-no-rpcsec.html#sshtun<br>b) setup kerberos and use sec=3Dkrb5p mount optio=
n<br>Is there any other way I can easily setup a secure channel between NFS=
 client and a server?<br><br><br>- My second question is: of the above two =
which one is the best option that will represent the overhead of NFS with s=
ecure channel? I would imagine that the first option (with SSH port forward=
ing) will incur more overhead than the second one due to memory copy and me=
ssaging between the NFS and SSH process. Can anyone please confirm this and=
 suggest and quick way to setup NFS with secure channel in way that will co=
rrectly represent the NFS overhead? Pointers to setup examples, if any, wil=
l be very helpful.<br><br>Thanks.<br><br>Regards,<br>Fantoosh<span style=3D=
"font-family: monospace;"></span><span style=3D"font-family: monospace;"></=
span><tt class=3D"OPTION"></tt><br></div><br /><hr />Find a local pizza pla=
ce, movie theater, and more=85.then map the best route! <a href=3D'http://m=
aps.live.com/default.aspx?v=3D2&ss=3Dyp.bars~yp.pizza~yp.movie%20theater&cp=
=3D42.358996~-71.056691&style=3Dr&lvl=3D13&tilt=3D-90&dir=3D0&alt=3D-1000&s=
cene=3D950607&encType=3D1&FORM=3DMGAC01' target=3D'_new'>Find it!</a></body=
>
</html>=

--_a2d22b76-0790-483a-aaa5-2cc84d3ddfdd_--


--===============0559158263==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============0559158263==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0559158263==--
