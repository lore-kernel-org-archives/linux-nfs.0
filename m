Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8525C43381
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 07:57:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ABD0420835
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 07:57:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="auMIr/ob"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725747AbfCGH5x (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 02:57:53 -0500
Received: from mail-lj1-f194.google.com ([209.85.208.194]:35018 "EHLO
        mail-lj1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725554AbfCGH5w (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 02:57:52 -0500
Received: by mail-lj1-f194.google.com with SMTP id t13so13380632lji.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 Mar 2019 23:57:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=8PRmHlX+xlXLIe3JaFBcpXcutpVS1z600qqQb4S/UwA=;
        b=auMIr/obPI3bwFJbFvpcvD1u5KnKYOnQ7Jqq0u6NRDtHb+NlVIgrlw4Ap+gAdiGmCS
         AXnVmC12DXnvt8DwiX5VUcewJZvz5/b+An0IZ6t+gTkEIeBK7+UvcfnsN2ahjCanpLga
         yXf2G4VyYMEipbYzoiwmlmV+Q6Ldeo1cK6wnpCemKKSX9rLITnBfksgk25pASrm3P/p8
         wheOCjEMIgTbHWPArSK/LBub/Fo/H6oTmXjUY3Bj8chTV0cLd6gtMRqySDntUm8Yrs06
         UpTM2BNRg3ZxRtL/H73Qv3hhHrE+ULLwr46Za7yBvZ+vEWB83OWmREhMEy2f6CDijAHl
         lQ4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=8PRmHlX+xlXLIe3JaFBcpXcutpVS1z600qqQb4S/UwA=;
        b=PB8jTb+0U5Z7RcsKo6C56uuUsHNCof3W63ZH6Q/u0S0IHQsyr1aayjGtOcr6bSPbuj
         xSkUbZlVX24MAhf7BMPezvNhZDwZ111AYPibZXPtnBHH4hf6HfPvJJRG3tG0AEHEyGx6
         8eivfXkEW5N+93Gbv/7UWXBHodbnpBKLwG7DQrzbTY2H1sqZugFMoxJJQF+uZcxKwbe6
         w333by0ZedznXlYf3Yg+7CUBSplynpOEbFyaZauKwgc9vfgbDA2XYmcER3pc0RJjLWeq
         TxYSFvfCbZ9qCrerhPTAmY3FFJRKWpezAvCEtthOKx/Qc+4q/AkJRSqokjq0yjEnl6As
         DH7Q==
X-Gm-Message-State: APjAAAXrXYx8+2WdZL7JvOS8p8O2PDW9JBWdy24jJs6noG9CYc7iLLrL
        lpl21GapafU33UWJoQceLO843YPpT/g7mQbEHMs=
X-Google-Smtp-Source: APXvYqx/lLykk5AfUCQ0N2rnYWNsINscehCyENm38E5GBW0r/ngIjxvqqyF+t8+3tbOV2XsOaRxAwKwY1scbXol8BlY=
X-Received: by 2002:a2e:680e:: with SMTP id c14mr4956331lja.51.1551945469060;
 Wed, 06 Mar 2019 23:57:49 -0800 (PST)
MIME-Version: 1.0
References: <CAP8UQm+od+oU63049_hgitTcBepCeG0vFBPHG90=WruVXGU_mw@mail.gmail.com>
 <CAP8UQm+gQZW5_FD5YMuh_fev0H7SAanwz92CpoA1Yyr7ooj7Hg@mail.gmail.com> <A469AE7A-B542-4BE7-BF1E-5EFD309DB0BB@redhat.com>
In-Reply-To: <A469AE7A-B542-4BE7-BF1E-5EFD309DB0BB@redhat.com>
From:   Kanika <jr.kanika@gmail.com>
Date:   Thu, 7 Mar 2019 13:27:38 +0530
Message-ID: <CAP8UQmJtNy+YX19gehz8dt2pnCi7icLGx5QEJaSZfb+nFnQwxg@mail.gmail.com>
Subject: Re: pnfs setup on Linux 4.15
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Benjamin,
Thanks for your reply. I suspected so but wanted to confirm. I tried
block/scsi layout as well but that isn't working either.

Based on an old thread on this list on "how to setup pnfs for block
layout", I set up an iscsi target on the DS and the initiators on the
MDS and client. All machines are running 4.15 kernel. Client as an
iscsi initiator but does not mount the device. MDS also an initiator
with an xfs filesystem mounted on the device. This mount point is
exported as an nfs share from the MDS. The client mounts the exported
MDS share.
By default LAYOUT_SCSI is used but the GETDEVICEINFO call keeps
failing with NFS4ERR_INVAL. As a result all reads/writes from the
client are routed to the MDS instead of the DS. Anything wrong with my
setup?
More details below.

Thanks,
jrk

----------------
On MDS
----------------
# cat /proc/partitions
major minor  #blocks  name

  11        0    1048575 sr0
 252        0   67108864 vda
 252        1   66107392 vda1
 252        2          1 vda2
 252        5     998400 vda5
   8        0    1048576 sda
   8        1    1047552 sda1  <-- iscsi device
root@ubuntu1804:/# mount | grep xfs
/dev/sda1 on /sudosrv type xfs (rw,relatime,attr2,inode64,noquota)
root@ubuntu1804:/# cat /etc/exports
/sudosrv        *(rw,sync,fsid=3D0,no_subtree_check,no_root_squash,pnfs)

------------------
On the client
------------------
root@ubuntu18_04_2:# cat /proc/partitions
major minor  #blocks  name

  11        0    1048575 sr0
 252        0   67108864 vda
 252        1   66107392 vda1
 252        2          1 vda2
 252        5     998400 vda5
   8        0    1048576 sda
   8        1    1047552 sda1
#mount
192.168.122.92:/ on /mnt type nfs4
(rw,relatime,vers=3D4.1,rsize=3D524288,wsize=3D524288,namlen=3D255,hard,pro=
to=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,clientaddr=3D192.168.122.83,loca=
l_lock=3Dnone,addr=3D192.168.122.92)

#cat /proc/self/mountstats
device 192.168.122.92:/ mounted on /mnt with fstype nfs4 statvers=3D1.1
        opts:
rw,vers=3D4.1,rsize=3D524288,wsize=3D524288,namlen=3D255,acregmin=3D3,acreg=
max=3D60,acdirmin=3D30,acdirmax=3D60,hard,proto=3Dtcp,timeo=3D600,retrans=
=3D2,sec=3Dsys,clientaddr=3D192.168.122.83,local_lock=3Dnone
        age:    2290
        impl_id:        name=3D'',domain=3D'',date=3D'0,0'
        caps:   caps=3D0x3ffff,wtmult=3D512,dtsize=3D32768,bsize=3D0,namlen=
=3D255
        nfsv4:
bm0=3D0xfdffbfff,bm1=3D0x40f9be3e,bm2=3D0x803,acl=3D0x3,sessions,pnfs=3DLAY=
OUT_SCSI
        sec:    flavor=3D1,pseudoflavor=3D1

Packet capture between the MDS and client
<snip>
119 2019-03-06 22:55:07.868442 192.168.122.83 =E2=86=92 192.168.122.92 NFS =
286
V4 Call LAYOUTGET
121 2019-03-06 22:55:07.876419 192.168.122.92 =E2=86=92 192.168.122.83 NFS =
266
V4 Reply (Call In 119) LAYOUTGET
122 2019-03-06 22:55:07.876950 192.168.122.83 =E2=86=92 192.168.122.92 NFS =
234
V4 Call GETDEVINFO
123 2019-03-06 22:55:07.877218 192.168.122.92 =E2=86=92 192.168.122.83 NFS =
158
V4 Reply (Call In 122) GETDEVINFO Status: NFS4ERR_INVAL
124 2019-03-06 22:55:07.877445 192.168.122.83 =E2=86=92 192.168.122.92 NFS =
282
V4 Call LAYOUTRETURN
126 2019-03-06 22:55:07.877539 192.168.122.83 =E2=86=92 192.168.122.92 NFS
1478 V4 Call WRITE StateID: 0xa6a8 Offset: 0 Len: 4096
128 2019-03-06 22:55:07.877746 192.168.122.92 =E2=86=92 192.168.122.83 NFS =
170
V4 Reply (Call In 124) LAYOUTRETURN
129 2019-03-06 22:55:07.901481 192.168.122.92 =E2=86=92 192.168.122.83 NFS =
246
V4 Reply (Call In 126) WRITE
131 2019-03-06 22:55:07.901702 192.168.122.83 =E2=86=92 192.168.122.92 NFS =
266
V4 Call CLOSE StateID: 0xa305
132 2019-03-06 22:55:07.901902 192.168.122.92 =E2=86=92 192.168.122.83 NFS =
246
V4 Reply (Call In 131) CLOSE
</snip>


#tshark -V -tad -n -r /tmp/iscsi-m-xfs.lcap frame.number =3D=3D 122
Network File System, Ops(2): SEQUENCE, GETDEVINFO
[Program Version: 4]
[V4 Procedure: COMPOUND (1)]
Tag: <EMPTY>
length: 0
contents: <EMPTY>
minorversion: 1
Operations (count: 2): SEQUENCE, GETDEVINFO
Opcode: SEQUENCE (53)
sessionid: 82bf805cbcdce1ef0c00000000000000
seqid: 0x00000004
slot id: 1
high slot id: 1
cache this?: No

Opcode: GETDEVINFO (47)
device ID: 01000000000000000000000000000000
layout type: LAYOUT4_SCSI (5)
maxcount: 527904
notification bitmap: 6
[Main Opcode: GETDEVINFO (47)]

#tshark -V -tad -n -r /tmp/iscsi-m-xfs.lcap frame.number =3D=3D 123
Opcode: GETDEVINFO (47)
         Status: NFS4ERR_INVAL (22)

On the client, nfs-blkmap is running and blocklayout driver is loaded

root@ubuntu18_04_2:~# systemctl status nfs-blkmap
* nfs-blkmap.service - pNFS block layout mapping daemon Loaded: loaded
(/lib/systemd/system/nfs-blkmap.service; disabled; vendor preset:
enabled)
 Active: active (running) since Wed 2019-03-06 22:41:54 PST; 1h 0min
ago Main PID: 485 (blkmapd) Tasks: 1 (limit: 4695) CGroup:
/system.slice/nfs-blkmap.service
   --485 /usr/sbin/blkmapd Mar 06 22:41:54 ubuntu18_04_2 blkmapd[485]:
open pipe file /run/rpc_pipefs/nfs/blocklayout failed: No such file or
directory Mar 06 22:41:54
ubuntu18_04_2 systemd[1]: Starting pNFS block layout mapping daemon...
Mar 06 22:41:54
ubuntu18_04_2 systemd[1]: nfs-blkmap.service: Can't open PID file
/run/blkmapd.pid (yet?) after start: No such file or di Mar 06
22:41:54
ubuntu18_04_2 systemd[1]: Started pNFS block layout mapping daemon.
Mar 06 22:52:54
ubuntu18_04_2 blkmapd[485]: blocklayout pipe file created

On Wed, 6 Mar 2019 at 21:31, Benjamin Coddington <bcodding@redhat.com> wrot=
e:
>
> Hi jrk,
>
> The upstream linux knfsd server currently only supports a very simple
> flexfiles layout where the MDS and the DS are the same server, so
> there's no way (yet) to configure knfsd to give out flexfiles layouts
> that point to other DS servers.
>
> See commit 9b9960a0ca4773e21c4b153ed355583946346b25 in the linux git
> repo for the work that implements this simple server.
>
> Ben
>
> On 6 Mar 2019, at 5:39, Kanika wrote:
>
> > Hi,
> > I am trying to deploy pnfs using the mainstream-ed NFSv4 server/client
> > available with 4.15 kernels. I have been able to setup the MDS and
> > client using the flexfile layout. I can't find any documentation on
> > how to inform MDS about the data servers.
> >
> > The setup I have so far:
> > Metadata server and data server are running Ubuntu 18.04
> > Client is Centos 7.5
> >
> > MDS (intended), ip: 192.168.122.92
> > root@ubuntu1804:~/#cat /etc/exports
> > /sudosrv *(rw,sync,fsid=3D0,no_subtree_check,no_root_squash,pnfs) <--
> > PNFS set
> > /sudosrv/share1 *(rw,sync,fsid=3D1,no_subtree_check,no_root_squash)
> >
> > Intended DS, ip: 192.168.122.83
> > root@ubuntu18_04_2:~#cat /etc/exports
> > /srv/homes *(rw,sync,fsid=3D4,no_root_squash,no_subtree_check)
> >
> > Client, ip:192.168.122.5 (Centos 7.5)
> > Mount the pseudo root filesystem exported by MDS
> >
> > #mount -t nfs -o v4.2 -o rw 192.168.122.92:/ /mnt/
> > #cat /proc/self/mountstats
> >
> > device nfsd mounted on /proc/fs/nfsd with fstype nfsd
> > device 192.168.122.92:/ mounted on /mnt with fstype nfs4 statvers=3D1.1
> > opts:
> > rw,vers=3D4.2,rsize=3D524288,wsize=3D524288,namlen=3D255,acregmin=3D3,a=
cregmax=3D60,acdirmin=3D30,acdirmax=3D60,hard,proto=3Dtcp,timeo=3D600,retra=
ns=3D2,sec=3Dsys,clientaddr=3D192.168.122.5,local_lock=3Dnone
> > age: 127
> > impl_id: name=3D'',domain=3D'',date=3D'0,0'
> > caps: caps=3D0x1fbffdf,wtmult=3D512,dtsize=3D32768,bsize=3D0,namlen=3D2=
55
> > nfsv4:
> > bm0=3D0xfdffbfff,bm1=3D0x40f9be3e,bm2=3D0x20803,acl=3D0x3,sessions,pnfs=
=3DLAYOUT_FLEX_FILES
> >  <--- flex file layout
> > sec: flavor=3D1,pseudoflavor=3D1
> >
> > I tried 2 ways to link MDS and DS
> > 1. Use the "refer" while exporting the DS share from MDS. This works
> > as referrals are expected to work but not like "pnfs".
> > 2. Mount the DS on MDS in a subdir of /sudosrv/share1. All IO
> > operations go only to the MDS as if it were a local share. No exchange
> > between the client and the DS.
> >
> > How can the DS be known to an MDS for a local filesystem like ext4?
> > Any help will be appreciated.
> >
> > Thanks,
> > jrk
