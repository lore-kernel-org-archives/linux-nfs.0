Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bn3nam01on0112.outbound.protection.outlook.com ([104.47.33.112]:32075
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750794AbdKUSab (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Nov 2017 13:30:31 -0500
From: Alexander Hermes <Alexander.Hermes@metaswitch.com>
To: Scott Mayhew <smayhew@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [Req for Help] Issues with SELinux (labelled) NFS after upgrading
 kernel 3.10.0-327 =>3.10.0-693
Date: Tue, 21 Nov 2017 18:30:28 +0000
Message-ID: <BN1PR0201MB0673393B908EB62C6691CEE4FC230@BN1PR0201MB0673.namprd02.prod.outlook.com>
References: <BN1PR0201MB067346CD800DDFDFF31CD2FFFC230@BN1PR0201MB0673.namprd02.prod.outlook.com>
 <20171121161725.ltsh6jk6dtetl7ui@tonberry.usersys.redhat.com>
In-Reply-To: <20171121161725.ltsh6jk6dtetl7ui@tonberry.usersys.redhat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Folks,
>=20
> I'm looking for some guidance on how to troubleshoot/debug an issue with =
(SELinux) labels over NFS that we've been having as a result of a kernel up=
grade - description below.
> I looked around on http://linux-nfs.org but was not able to find how to d=
ebug this kind of issue with labels - everything I found relates to more fu=
ndamental issues like mounts plain not working.=20
>=20
> With apologies for sending this to the devel mailing list, could you plea=
se help me get to the bottom of this? Or redirect me to somewhere / someone=
 that can?
>=20
> Thank you very much,
>=20
> Alexander Hermes
>=20
> ----
>=20
> ## Summary
>=20
> In upgrading our servers from CentOS 7.3 to 7.4 we upgraded the kernel fr=
om 3.10.0-327.36.2.el7.x86_64 to 3.10.0-693.2.2.el7.x86_64. As a result, NF=
S v4.2 mounts mounted via /etc/fstab at boot do not have proper SElinux lab=
el support - attempting to change labels on a mounted file leads to "Operat=
ion Not Supported". `ls -lZ` shows the incorrect labels. Upon rebooting to =
the earlier kernel version the issue goes away.
>=20
> ## Background
>=20
> As part of our gitlab HA deployment we use NFS to host data on a back end=
 server that is then mounted by application servers (cf. https://docs.gitla=
b.com/ce/administration/high_availability/nfs.html). To do this we have a f=
airly typical setup where the server (in this example "enfigitback2-devel")=
 exports a bunch of mounts via /etc/exports which are then mounted on a cou=
ple of application servers ("enfigitfront1-devel" / "enfigitfront2-devel").
>=20
> ## The issue
>=20
> On the new kernel I am not able to change or view the SELinux labels of f=
iles / directories mounted on the client:
>=20
> ```
> [root@enfigitfront2-devel ~]# chcon --recursive --type ssh_home_t=20
> /var/opt/gitlab/.ssh/authorized_keys
> chcon: failed to change context of=20
> '/var/opt/gitlab/.ssh/authorized_keys' to=20
> 'system_u:object_r:ssh_home_t:s0': Operation not supported=20
> [root@enfigitfront2-devel ~]# uname -r
> 3.10.0-693.2.2.el7.x86_64
> ```
> On the old kernel I am:
>=20
> ```
> [root@enfigitfront1-devel ~]# chcon --recursive --type ssh_home_t=20
> /var/opt/gitlab/.ssh/authorized_keys
> [root@enfigitfront1-devel ~]# uname -r
> 3.10.0-327.36.2.el7.x86_64
> ```
>=20
> We can't keep using the old kernel forever so I'd like to get to the bott=
om of this - what could this be due to? How can I debug this further to und=
erstand where the "Operation not supported" is coming from?
>=20
> ## Server details
> Distro: CentOS 7.3 / 7.4
> Kernel (`uname -r`):=20
>  * 3.10.0-514.10.2.el7.x86_64 (server)
> * 3.10.0-693.2.2.el7.x86_64 (client - new)
> * 3.10.0-327.36.2.el7.x86_64 (client - old)
> nfs-utils: RPM package version 1.3.0
>=20
> =20
> Server mount option example:
> /export/.ssh 172.18.10.148(rw,sync,no_root_squash)=20
> 172.18.10.151(rw,sync,no_root_squash)

Add "security_label" to the export options above.  If you don't see "securi=
ty_label" listed in the exports(5) man page then you need to upgrade your n=
fs-utils package.

-Scott

>=20
> Client mount options (/etc/fstab):
> enfigitback2-devel.datcon.co.uk:/export/.ssh    /var/opt/gitlab/.ssh    n=
fs     defaults,soft,v4.2,rsize=3D1048576,wsize=3D1048576,noatime,_netdev,l=
ookupcache=3Dnone 0       0
>=20
> ## Debugging I've done
>=20
> ### Mounting by hand
> I tried to mount one of the exported mounts "by hand" using `mount` and f=
ound the following:
> * mounting the same export on a different mount point using the same=20
> options as in /etc/fstab yields a mount that has the same issue
> * mounting with `nosharecache` results in a mount that *does not* have th=
e issue.
>=20
>=20


Hi Scott,

Thank you for pointing out "security_label". I have applied the option...

	/export/.ssh 172.18.10.148(rw,sync,no_root_squash,security_label) 172.18.1=
0.151(rw,sync,no_root_squash,security_label)

and rebooted both server and client (in that order), but I still see the sa=
me behaviour as before on the server with the uplevel kernel:

	[root@enfigitfront2-devel ~]# chcon --recursive --type ssh_home_t /var/opt=
/gitlab/.ssh/authorized_keys
	chcon: failed to change context of '/var/opt/gitlab/.ssh/authorized_keys' =
to 'system_u:object_r:ssh_home_t:s0': Operation not supported

I notice that the exports(5) man page mentions " This will only work if all=
 clients use a consistent security policy." under security_label. I'm not s=
ure what a "consistent security policy" means - what does this mean in term=
s of options/configuration?=20

Thanks for the help,
Alex
