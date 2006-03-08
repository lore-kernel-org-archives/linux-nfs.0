From: "Vijay Chauhan" <kernel.vijay@gmail.com>
Subject: NFS mount error
Date: Wed, 8 Mar 2006 14:29:51 +0530
Message-ID: <a9ed420f0603080059n65c8ee01t978a5e9f58ddcbd9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_1612_6301992.1141808391851"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGuWT-0005oV-Ed
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 00:59:57 -0800
Received: from xproxy.gmail.com ([66.249.82.193])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FGuWP-0005pv-Ex
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 00:59:57 -0800
Received: by xproxy.gmail.com with SMTP id h31so89622wxd
        for <nfs@lists.sourceforge.net>; Wed, 08 Mar 2006 00:59:51 -0800 (PST)
To: nfs@lists.sourceforge.net
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

------=_Part_1612_6301992.1141808391851
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

hi,
im doing mount/unmount in an infinte loop
while [ "a" =3D=3D "a" ];
do
mount -t nfs -o tcp server:/filepath /mount-point
unmount -at nfs
done

after some successful mount/unmount its giving error message like

RPC: can't bind to reserved port.

what does it means?

TIA,
Vijay

------=_Part_1612_6301992.1141808391851
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<div>hi,</div>
<div>im doing mount/unmount in an infinte loop </div>
<div>while [ &quot;a&quot; =3D=3D &quot;a&quot; ];</div>
<div>do</div>
<div>mount -t nfs -o tcp server:/filepath /mount-point</div>
<div>unmount -at nfs</div>
<div>done</div>
<div>&nbsp;</div>
<div>after some successful mount/unmount its giving error message like </di=
v>
<div>&nbsp;</div>
<div>RPC: can't bind to reserved port.</div>
<div>&nbsp;</div>
<div>what does it means?</div>
<div>&nbsp;</div>
<div>TIA,</div>
<div>Vijay</div>

------=_Part_1612_6301992.1141808391851--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
