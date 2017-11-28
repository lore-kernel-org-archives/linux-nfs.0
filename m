Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-cys01nam02on0135.outbound.protection.outlook.com ([104.47.37.135]:10274
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752561AbdK1KJ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Nov 2017 05:09:59 -0500
From: Alexander Hermes <Alexander.Hermes@metaswitch.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Scott Mayhew <smayhew@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [Req for Help] Issues with SELinux (labelled) NFS after upgrading
 kernel 3.10.0-327 =>3.10.0-693
Date: Tue, 28 Nov 2017 10:09:52 +0000
Message-ID: <BN1PR0201MB067317A6EDC7232B2A16BC00FC3A0@BN1PR0201MB0673.namprd02.prod.outlook.com>
References: <BN1PR0201MB067346CD800DDFDFF31CD2FFFC230@BN1PR0201MB0673.namprd02.prod.outlook.com>
 <20171121161725.ltsh6jk6dtetl7ui@tonberry.usersys.redhat.com>
 <BN1PR0201MB0673393B908EB62C6691CEE4FC230@BN1PR0201MB0673.namprd02.prod.outlook.com>
 <20171127135137.jbbfggdi7jbncve3@tonberry.usersys.redhat.com>
 <20171127155727.GA25581@fieldses.org>
In-Reply-To: <20171127155727.GA25581@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Tue, 21 Nov 2017, Alexander Hermes wrote:
>=20
> > > Folks,
> > >=20
> > > I'm looking for some guidance on how to troubleshoot/debug an issue w=
ith (SELinux) labels over NFS that we've been having as a result of a kerne=
l upgrade - description below.
> > > I looked around on http://linux-nfs.org but was not able to find how =
to debug this kind of issue with labels - everything I found relates to mor=
e fundamental issues like mounts plain not working.=20
> > >=20
> > > With apologies for sending this to the devel mailing list, could you =
please help me get to the bottom of this? Or redirect me to somewhere / som=
eone that can?
> > >=20
> > > Thank you very much,
> > >=20
> > > Alexander Hermes
> > >=20
> > > ----
> > >=20
> > > ## Summary
> > >=20
> > > In upgrading our servers from CentOS 7.3 to 7.4 we upgraded the kerne=
l from 3.10.0-327.36.2.el7.x86_64 to 3.10.0-693.2.2.el7.x86_64. As a result=
, NFS v4.2 mounts mounted via /etc/fstab at boot do not have proper SElinux=
 label support - attempting to change labels on a mounted file leads to "Op=
eration Not Supported". `ls -lZ` shows the incorrect labels. Upon rebooting=
 to the earlier kernel version the issue goes away.
> > >=20
> > > ## Background
> > >=20
> > > As part of our gitlab HA deployment we use NFS to host data on a back=
 end server that is then mounted by application servers (cf. https://docs.g=
itlab.com/ce/administration/high_availability/nfs.html). To do this we have=
 a fairly typical setup where the server (in this example "enfigitback2-dev=
el") exports a bunch of mounts via /etc/exports which are then mounted on a=
 couple of application servers ("enfigitfront1-devel" / "enfigitfront2-deve=
l").
> > >=20
> > > ## The issue
> > >=20
> > > On the new kernel I am not able to change or view the SELinux labels =
of files / directories mounted on the client:
> > >=20
> > > ```
> > > [root@enfigitfront2-devel ~]# chcon --recursive --type ssh_home_t=20
> > > /var/opt/gitlab/.ssh/authorized_keys
> > > chcon: failed to change context of=20
> > > '/var/opt/gitlab/.ssh/authorized_keys' to
> > > 'system_u:object_r:ssh_home_t:s0': Operation not supported=20
> > > [root@enfigitfront2-devel ~]# uname -r
> > > 3.10.0-693.2.2.el7.x86_64
> > > ```
> > > On the old kernel I am:
> > >=20
> > > ```
> > > [root@enfigitfront1-devel ~]# chcon --recursive --type ssh_home_t=20
> > > /var/opt/gitlab/.ssh/authorized_keys
> > > [root@enfigitfront1-devel ~]# uname -r
> > > 3.10.0-327.36.2.el7.x86_64
> > > ```
> > >=20
> > > We can't keep using the old kernel forever so I'd like to get to the =
bottom of this - what could this be due to? How can I debug this further to=
 understand where the "Operation not supported" is coming from?
> > >=20
> > > ## Server details
> > > Distro: CentOS 7.3 / 7.4
> > > Kernel (`uname -r`):=20
> > >  * 3.10.0-514.10.2.el7.x86_64 (server)
> > > * 3.10.0-693.2.2.el7.x86_64 (client - new)
> > > * 3.10.0-327.36.2.el7.x86_64 (client - old)
> > > nfs-utils: RPM package version 1.3.0
> > >=20
> > > =20
> > > Server mount option example:
> > > /export/.ssh 172.18.10.148(rw,sync,no_root_squash)
> > > 172.18.10.151(rw,sync,no_root_squash)
> >=20
> > Add "security_label" to the export options above.  If you don't see "se=
curity_label" listed in the exports(5) man page then you need to upgrade yo=
ur nfs-utils package.
> >=20
> > -Scott
> >=20
> > >=20
> > > Client mount options (/etc/fstab):
> > > enfigitback2-devel.datcon.co.uk:/export/.ssh    /var/opt/gitlab/.ssh =
   nfs     defaults,soft,v4.2,rsize=3D1048576,wsize=3D1048576,noatime,_netd=
ev,lookupcache=3Dnone 0       0
> > >=20
> > > ## Debugging I've done
> > >=20
> > > ### Mounting by hand
> > > I tried to mount one of the exported mounts "by hand" using `mount` a=
nd found the following:
> > > * mounting the same export on a different mount point using the=20
> > > same options as in /etc/fstab yields a mount that has the same=20
> > > issue
> > > * mounting with `nosharecache` results in a mount that *does not* hav=
e the issue.
> > >=20
> > >=20
> >=20
> >=20
> > Hi Scott,
> >=20
> > Thank you for pointing out "security_label". I have applied the option.=
..
> >=20
> > 	/export/.ssh 172.18.10.148(rw,sync,no_root_squash,security_label)=20
> > 172.18.10.151(rw,sync,no_root_squash,security_label)
> >=20
> > and rebooted both server and client (in that order), but I still see th=
e same behaviour as before on the server with the uplevel kernel:
> >=20
> > 	[root@enfigitfront2-devel ~]# chcon --recursive --type ssh_home_t /var=
/opt/gitlab/.ssh/authorized_keys
> > 	chcon: failed to change context of=20
> > '/var/opt/gitlab/.ssh/authorized_keys' to=20
> > 'system_u:object_r:ssh_home_t:s0': Operation not supported
> >=20
> > I notice that the exports(5) man page mentions " This will only work if=
 all clients use a consistent security policy." under security_label. I'm n=
ot sure what a "consistent security policy" means - what does this mean in =
terms of options/configuration?=20
>=20
> I'm assuming  that means you don't want some clients using full=20
> labeled NFS, others mounting with the context=3D mount option, and=20
> others with SELinux completely disabled.  With labeled NFS, the=20
> creation and enforcement of labels happens on the client side and the=20
> server just stores the labels.

So also for example if the clients disagree about how to label files in you=
r home directory, or something, then things will likely break.  I don't kno=
w how big a problem that is in practice.

--b.

>=20
> Anyways, I missed the fact that your clients are using an earlier=20
> kernel.  In order to get the desired behavior when mounting an NFS=20
> server that is using the "security_label" export option, you're pretty=20
> much going to need to run an updated kernel on the clients too...
> specifically one with commit 0b4d3452b "security/selinux: allow=20
> security_sb_clone_mnt_opts to enable/disable native labeling behavior".
> AFAIK CentOS 7.4 should have it (because RHEL 7.4 has it).
>=20
> -Scott
>=20
>=20
> >=20
> > Thanks for the help,
> > Alex
> > --

Hi,

Thanks for the reply. Yes, I imagine there'd be problems if clients are con=
fused about what labels are applied, but I just wanted to check if anyone k=
new of that actually preventing other clients from reading or setting label=
s at all (throwing "Operation not supported" errors). It sounds from what y=
ou are saying like that is _not_ the case.

Scott, I just want to clarify your comment about clients using an earlier k=
ernel.  Since my original message we now have the following kernels

Server: 			3.10.0-693.5.2.el7.x86_64
Client (working): 	3.10.0-327.36.2.el7.x86_64
Client (non-working): 	3.10.0-693.2.2.el7.x86_64

So it's the _working_ client which has the down-level kernel. Are you sayin=
g it needs to be up-level also for this to work? Or do you mean that all of=
 the versions are too old somehow?=20
This was working when all servers were down-level (CentOS 7.3 kernel so 3.1=
0-327) _without_ the "security_label" exports option - did the new kernel t=
ighten the security such that this is now required?

Separately, do either of you know of a sensible way I can debug the root ca=
use for the issue further (to get a more detail why "Operation not supporte=
d" is thrown)? I don't know the kernel source at all so just reading the co=
de is not viable for me (without some guidance), but is there some logging =
or more verbose output I can turn on?

Alex
