Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bn3nam01on0134.outbound.protection.outlook.com ([104.47.33.134]:52016
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750794AbdKUPrl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Nov 2017 10:47:41 -0500
From: Alexander Hermes <Alexander.Hermes@metaswitch.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [Req for Help] Issues with SELinux (labelled) NFS after upgrading
 kernel 3.10.0-327 =>3.10.0-693
Date: Tue, 21 Nov 2017 15:47:39 +0000
Message-ID: <BN1PR0201MB067346CD800DDFDFF31CD2FFFC230@BN1PR0201MB0673.namprd02.prod.outlook.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Folks,

I'm looking for some guidance on how to troubleshoot/debug an issue with (S=
ELinux) labels over NFS that we've been having as a result of a kernel upgr=
ade - description below.
I looked around on http://linux-nfs.org but was not able to find how to deb=
ug this kind of issue with labels - everything I found relates to more fund=
amental issues like mounts plain not working.=20

With apologies for sending this to the devel mailing list, could you please=
 help me get to the bottom of this? Or redirect me to somewhere / someone t=
hat can?

Thank you very much,

Alexander Hermes

----

## Summary

In upgrading our servers from CentOS 7.3 to 7.4 we upgraded the kernel from=
 3.10.0-327.36.2.el7.x86_64 to 3.10.0-693.2.2.el7.x86_64. As a result, NFS =
v4.2 mounts mounted via /etc/fstab at boot do not have proper SElinux label=
 support - attempting to change labels on a mounted file leads to "Operatio=
n Not Supported". `ls -lZ` shows the incorrect labels. Upon rebooting to th=
e earlier kernel version the issue goes away.

## Background

As part of our gitlab HA deployment we use NFS to host data on a back end s=
erver that is then mounted by application servers (cf. https://docs.gitlab.=
com/ce/administration/high_availability/nfs.html). To do this we have a fai=
rly typical setup where the server (in this example "enfigitback2-devel") e=
xports a bunch of mounts via /etc/exports which are then mounted on a coupl=
e of application servers ("enfigitfront1-devel" / "enfigitfront2-devel").

## The issue

On the new kernel I am not able to change or view the SELinux labels of fil=
es / directories mounted on the client:

```
[root@enfigitfront2-devel ~]# chcon --recursive --type ssh_home_t /var/opt/=
gitlab/.ssh/authorized_keys
chcon: failed to change context of '/var/opt/gitlab/.ssh/authorized_keys' t=
o 'system_u:object_r:ssh_home_t:s0': Operation not supported
[root@enfigitfront2-devel ~]# uname -r
3.10.0-693.2.2.el7.x86_64
```
On the old kernel I am:

```
[root@enfigitfront1-devel ~]# chcon --recursive --type ssh_home_t /var/opt/=
gitlab/.ssh/authorized_keys
[root@enfigitfront1-devel ~]# uname -r
3.10.0-327.36.2.el7.x86_64
```

We can't keep using the old kernel forever so I'd like to get to the bottom=
 of this - what could this be due to? How can I debug this further to under=
stand where the "Operation not supported" is coming from?

## Server details
Distro: CentOS 7.3 / 7.4
Kernel (`uname -r`):=20
 * 3.10.0-514.10.2.el7.x86_64 (server)
* 3.10.0-693.2.2.el7.x86_64 (client - new)
* 3.10.0-327.36.2.el7.x86_64 (client - old)
nfs-utils: RPM package version 1.3.0

=20
Server mount option example:
/export/.ssh 172.18.10.148(rw,sync,no_root_squash) 172.18.10.151(rw,sync,no=
_root_squash)

Client mount options (/etc/fstab):
enfigitback2-devel.datcon.co.uk:/export/.ssh    /var/opt/gitlab/.ssh    nfs=
     defaults,soft,v4.2,rsize=3D1048576,wsize=3D1048576,noatime,_netdev,loo=
kupcache=3Dnone 0       0

## Debugging I've done

### Mounting by hand
I tried to mount one of the exported mounts "by hand" using `mount` and fou=
nd the following:
* mounting the same export on a different mount point using the same option=
s as in /etc/fstab yields a mount that has the same issue
* mounting with `nosharecache` results in a mount that *does not* have the =
issue.



