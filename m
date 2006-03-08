From: "prafulla chandra vejendla" <v.prafulla@gmail.com>
Subject: problem while mounting the root file system through NFS
Date: Wed, 8 Mar 2006 16:29:29 +0530
Message-ID: <26d3a31c0603080259h3161ca48s5647dcff17f7c960@mail.gmail.com>
References: <26d3a31c0603080256w62a6f755s8ac487dcb371ddeb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_10386_3452952.1141815569116"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGwOB-0001A3-Ty
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 02:59:31 -0800
Received: from nproxy.gmail.com ([64.233.182.193])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FGwOA-00072U-JR
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 02:59:32 -0800
Received: by nproxy.gmail.com with SMTP id l36so111454nfa
        for <nfs@lists.sourceforge.net>; Wed, 08 Mar 2006 02:59:29 -0800 (PST)
To: nfs@lists.sourceforge.net
In-Reply-To: <26d3a31c0603080256w62a6f755s8ac487dcb371ddeb@mail.gmail.com>
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

------=_Part_10386_3452952.1141815569116
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

 Hi all,
i am working on osk5912 board . i am using linux kernel 2.6.11.3 with the
nfs configuration settings

CONFIG_NFS_FS=3Dy

CONFIG_NFS_V3=3Dy

CONFIG_ROOT_NFS=3Dy

and i shared the directory which is on my host by editing the exports file
in the /etc directory this is as follows

/data/rootfs2.6 *(rw,no_root_squash,no_all_squash,sync) and i restarted the
network services by using the exportfs as well as the service nfs restart.

and i have given the bootarguments for my bootloader u boot as

setenv bootargs console=3DttyS0,115200n8 noinitrd
ip=3D10.100.132.16:10.100.132.67:${GATEWAY_IP}:${NETMASK}:osk:eth0:off


root =3D /dev/nfs rw nfsroot=3D${PC_IP}:/data/rootfs2.6,nolock mem=3D32M

# saveenv

but i am getting error after booting as

eth0: link up

ip-config :complete

device =3D eth0 addr  =3D10.100.132.16 maks=3D255.255.255.0 gw =3D10.100.13=
2.1 host
=3D osk domain=3D ,nis-domain =3D (none)

bootserver=3D10.100.132.67 rootserver =3D10.100.132.67

portmap:server 10.100.132.67 NOT RESPONDING ,TIMED OUT

ROOT-NFS :UNABLE TO GET NFSD PORT NUMBER FROM SERVER U;SING DEFAULT

MOUNT:SERVER 10.100.132.67 NOT RESPONDING ,TIMED OUT

ROOT-NFS :SSERVER RETURNED ERROR -5 WHILE MOUNTING /DATA/ROOTFS2.6

VFS UNABLE TO MOUNT TRYING FOR FLOPPY

VFS NO ROOT YET ,RETRYING TO MOUNT ROOT ON NFS (UNKNOWN-BLOCK(2,0))

VFS NO ROOT YET ,RETRYING TO MOUNT ROOT ON NFS (UNKNOWN-BLOCK(2,0))

VFS NO ROOT YET ,RETRYING TO MOUNT ROOT ON NFS (UNKNOWN-BLOCK(2,0))

........................................... PLEASE APPEND CORRECT "ROOT =3D
"BOOT OPTION..................

WHAT COULD BE THE PROBLEM

WHETHER IN KERNEL COMPILING OPTIONS OR IN NFS SERVER IN THE HOST
..............?????

--PRAFULLA CHANDRA

------=_Part_10386_3452952.1141815569116
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<span class=3D"gmail_quote"><br></span>
<div style=3D"DIRECTION: ltr">
<div>Hi all,</div>
<div>i am working on osk5912 board . i am using linux kernel <a onclick=3D"=
return top.js.OpenExtLink(window,event,this)" href=3D"http://2.6.11.3/" tar=
get=3D"_blank">2.6.11.3</a> with the nfs configuration settings </div>
<div><font face=3D"Times New Roman">
<p align=3D"left">CONFIG_NFS_FS=3Dy</p>
<p align=3D"left">CONFIG_NFS_V3=3Dy</p>
<p align=3D"left">CONFIG_ROOT_NFS=3Dy </p>
<p align=3D"left">and i shared the directory which is on my host by editing=
 the exports file in the /etc directory this is as follows</p><font face=3D=
"Times New Roman"><font face=3D"Times New Roman">
<p align=3D"left">/data/rootfs2.6 *(rw,no_root_squash,no_all_squash,sync) a=
nd i restarted the network services by using the exportfs as well as the se=
rvice nfs restart.</p>
<p align=3D"left">and i have given the bootarguments for my bootloader u bo=
ot as</p><font face=3D"Times New Roman">
<p align=3D"left">setenv bootargs console=3DttyS0,115200n8 noinitrd ip=3D<a=
 onclick=3D"return top.js.OpenExtLink(window,event,this)" href=3D"http://10=
.100.132.16:10/" target=3D"_blank">10.100.132.16:10</a>.100.132.67:${GATEWA=
Y_IP}:${NETMASK}:osk:eth0:off=20
</p>
<p align=3D"left">root =3D /dev/nfs rw nfsroot=3D${PC_IP}:/data/rootfs2.6,n=
olock mem=3D32M</p>
<p align=3D"left"># saveenv</p>
<p align=3D"left">but i am getting error after booting as</p>
<p align=3D"left">eth0: link up</p>
<p align=3D"left">ip-config :complete</p>
<p align=3D"left">device =3D eth0 addr&nbsp; =3D<a onclick=3D"return top.js=
.OpenExtLink(window,event,this)" href=3D"http://10.100.132.16/" target=3D"_=
blank">10.100.132.16</a> maks=3D<a onclick=3D"return top.js.OpenExtLink(win=
dow,event,this)" href=3D"http://255.255.255.0/" target=3D"_blank">
255.255.255.0</a> gw =3D<a onclick=3D"return top.js.OpenExtLink(window,even=
t,this)" href=3D"http://10.100.132.1/" target=3D"_blank">10.100.132.1</a> h=
ost =3D osk domain=3D ,nis-domain =3D (none) </p>
<p align=3D"left">bootserver=3D<a onclick=3D"return top.js.OpenExtLink(wind=
ow,event,this)" href=3D"http://10.100.132.67/" target=3D"_blank">10.100.132=
.67</a> rootserver =3D<a onclick=3D"return top.js.OpenExtLink(window,event,=
this)" href=3D"http://10.100.132.67/" target=3D"_blank">
10.100.132.67</a> </p>
<p align=3D"left">portmap:server <a onclick=3D"return top.js.OpenExtLink(wi=
ndow,event,this)" href=3D"http://10.100.132.67/" target=3D"_blank">10.100.1=
32.67</a> NOT RESPONDING ,TIMED OUT</p>
<p align=3D"left">ROOT-NFS :UNABLE TO GET NFSD PORT NUMBER FROM SERVER U;SI=
NG DEFAULT</p>
<p align=3D"left">MOUNT:SERVER <a onclick=3D"return top.js.OpenExtLink(wind=
ow,event,this)" href=3D"http://10.100.132.67/" target=3D"_blank">10.100.132=
.67</a> NOT RESPONDING ,TIMED OUT</p>
<p align=3D"left">ROOT-NFS :SSERVER RETURNED ERROR -5 WHILE MOUNTING /DATA/=
ROOTFS2.6</p>
<p align=3D"left">VFS UNABLE TO MOUNT TRYING FOR FLOPPY</p>
<p align=3D"left">VFS NO ROOT YET ,RETRYING TO MOUNT ROOT ON NFS (UNKNOWN-B=
LOCK(2,0))</p>
<p align=3D"left">VFS NO ROOT YET ,RETRYING TO MOUNT ROOT ON NFS (UNKNOWN-B=
LOCK(2,0))</p>
<p align=3D"left">VFS NO ROOT YET ,RETRYING TO MOUNT ROOT ON NFS (UNKNOWN-B=
LOCK(2,0))</p>
<p align=3D"left">........................................... PLEASE APPEND=
 CORRECT &quot;ROOT =3D &quot;BOOT OPTION..................</p>
<p align=3D"left">WHAT COULD BE THE PROBLEM </p>
<p align=3D"left">WHETHER IN KERNEL COMPILING OPTIONS OR IN NFS SERVER IN T=
HE HOST ..............?????</p>
<p align=3D"left">--PRAFULLA CHANDRA</p></font></font></font></font></div><=
/div>

------=_Part_10386_3452952.1141815569116--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
