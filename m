From: "Vijay Chauhan" <kernel.vijay@gmail.com>
Subject: mounting NFS with TCP option
Date: Tue, 7 Mar 2006 20:33:45 +0530
Message-ID: <a9ed420f0603070703x7a864804h9e6e2786b6dcdd19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_6787_24752940.1141743825262"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGdj4-0007QN-BZ
	for nfs@lists.sourceforge.net; Tue, 07 Mar 2006 07:03:50 -0800
Received: from xproxy.gmail.com ([66.249.82.193])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FGdj3-0000Cj-3n
	for nfs@lists.sourceforge.net; Tue, 07 Mar 2006 07:03:50 -0800
Received: by xproxy.gmail.com with SMTP id r21so992938wxc
        for <nfs@lists.sourceforge.net>; Tue, 07 Mar 2006 07:03:45 -0800 (PST)
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

------=_Part_6787_24752940.1141743825262
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,
im mounting a remote file system like this:
while [ "a" =3D=3D "a" ];
do
mount -t nfs -o tcp server:/file-system-path /mnt-point
umount -at nfs
done

after few mounts it stop mounting the file system.

Can anyone give any hints/suggestion
Also does tcp have any effect in this case?

TIA,
Vijay

------=_Part_6787_24752940.1141743825262
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<div>Hi,</div>
<div>im mounting a remote file system like this:</div>
<div>while [ &quot;a&quot; =3D=3D &quot;a&quot; ];</div>
<div>do</div>
<div>mount -t nfs -o tcp server:/file-system-path /mnt-point</div>
<div>umount -at nfs</div>
<div>done</div>
<div>&nbsp;</div>
<div>after few mounts it stop mounting the file system.</div>
<div>&nbsp;</div>
<div>Can anyone give any hints/suggestion</div>
<div>Also does tcp have any effect in this case?</div>
<div>&nbsp;</div>
<div>TIA,</div>
<div>Vijay</div>

------=_Part_6787_24752940.1141743825262--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
