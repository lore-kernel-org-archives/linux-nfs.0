Return-Path: <SRS0=3/9x=RL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63862C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 07:06:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3002920811
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 07:06:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kGdIN1uT"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726379AbfCHHGB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Mar 2019 02:06:01 -0500
Received: from mail-lj1-f195.google.com ([209.85.208.195]:33477 "EHLO
        mail-lj1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726039AbfCHHGB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2019 02:06:01 -0500
Received: by mail-lj1-f195.google.com with SMTP id z7so16524353lji.0
        for <linux-nfs@vger.kernel.org>; Thu, 07 Mar 2019 23:05:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=u66zyo9eiI5b9Y/aVQSWXoXRO4ezCxl8u3CB6dlErjA=;
        b=kGdIN1uTAz4JgW8YJV7yBfaeiBUnXy19gAuse7T4foyxD6z7jHxLcMZH5ReaL5fy1b
         SKRyZmqBaluCdTa1p51gC4s6Qxu91iTuQkIgHxZGEd+wSMeg3QHtRfgjkXlYpda1vXAj
         CdCLdGeLapeelK3BJleJgMpP20XS00GUZxNZaUoaMmi5GCeX0XYcLJ/rDuwvr2anTA2N
         Hj+yFhhNMVZUuWXip+4I1Ea6zm7wwQPb3FngaWljmctxhj5vDW9PcbA+n16KMBgX9wrh
         oeGeZe1TiNmfll6LVq2kb9EBxL2c8sZEAhBKGecPTOHc8H4XAssjQv0jEGIBHaOZqavF
         8kXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=u66zyo9eiI5b9Y/aVQSWXoXRO4ezCxl8u3CB6dlErjA=;
        b=CnZDe/s3ytO5xXfYWxiJvX0an7IXmn9+3/mAFOXCdfEhZJRHiwZ0I3MxjixRAC9jLQ
         w0VD+9D81H+vLYOF3QaT7tIgUaszr1PwieM0qJBs24+HQcmSIX/gWkygKd50FRp68SeD
         dZ1GXASLkDM2wE9asFPcK3WCwDQDf0tcGh7kaxzepzk8biXjonqorOTyGTUWg5xDUOad
         cgGiwI46vx5c05GrcPKDT6n6yCawSdN1YguQL4NkgK7+KaCyJv44/iXicAL71YusTsUv
         l/YGXCZKicS3x56ZKzx5ZMbTAEg/ozAYX7X2nYMDRD1SQy6fNAoJACMJWozq2mkWkitc
         UwzQ==
X-Gm-Message-State: APjAAAVOTYbCv4+P+4/2ILidnQRB/8/bi9OmD2Y5tEhj41I/oE452k9f
        sJ0R/0keuCO2y6XZ4OMpn9Vm6MOZ85PmTrjH9Q0=
X-Google-Smtp-Source: APXvYqwuZnhc4qyB/aKlLidq+NxmQC5Greh68clklFwjMYrHUu48wgTpDyW0jqEvz1MI48C+mINCJ630vMKdDDgrIr0=
X-Received: by 2002:a2e:9e57:: with SMTP id g23mr7972737ljk.124.1552028758889;
 Thu, 07 Mar 2019 23:05:58 -0800 (PST)
MIME-Version: 1.0
References: <CAP8UQm+od+oU63049_hgitTcBepCeG0vFBPHG90=WruVXGU_mw@mail.gmail.com>
 <CAP8UQm+gQZW5_FD5YMuh_fev0H7SAanwz92CpoA1Yyr7ooj7Hg@mail.gmail.com>
 <A469AE7A-B542-4BE7-BF1E-5EFD309DB0BB@redhat.com> <CAP8UQm+j4Rog_AK8yiOwTY_3pBbV3OwKU7KvoU2B064hmC9gWA@mail.gmail.com>
 <C235C237-B75C-4EED-B2F1-1F5E084B21CD@redhat.com>
In-Reply-To: <C235C237-B75C-4EED-B2F1-1F5E084B21CD@redhat.com>
From:   Kanika <jr.kanika@gmail.com>
Date:   Fri, 8 Mar 2019 12:35:48 +0530
Message-ID: <CAP8UQm+tBWfiG4yVe=YihyOswGy00ZbXLMTcdQs-YG_M7FFRMg@mail.gmail.com>
Subject: Re: pnfs setup on Linux 4.15
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 7 Mar 2019 at 16:42, Benjamin Coddington <bcodding@redhat.com> wrot=
e:
>
> On 7 Mar 2019, at 2:51, Kanika wrote:
>
> > Hi Benjamin,
> > Thanks for your reply. I suspected so but wanted to confirm. I tried
> > block/scsi layout as well but that isn't working either.
> >
> > Based on an old thread on this list on "how to setup pnfs for block
> > layout", I set up an iscsi target on the DS and the initiators on the M=
DS
> > and client. All machines are running 4.15 kernel. Client as an iscsi
> > initiator but does not mount the device. MDS also an initiator with an =
xfs
> > filesystem mounted on the device. This mount point is exported as an nf=
s
> > share from the MDS. The client mounts the exported MDS share.
> > By default LAYOUT_SCSI is used but the GETDEVICEINFO call keeps failing
> > with NFS4ERR_INVAL. As a result all reads/writes from the client are ro=
uted
> > to the MDS instead of the DS. Anything wrong with my setup?
>
> The SCSI layout needs to work with whole SCSI devices, not partitions.
>
> Try putting your XFS on /dev/sda instead of /dev/sda1.
>
> Ben
Hi Ben,
Thanks for the pointer. I tried this but still no luck, see the same
error for GETDEVICEINFO. Anything else I am missing?

On MDS:
root@ubuntu1604:~# lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
NAME   FSTYPE  SIZE MOUNTPOINT LABEL
sda        xfs           1G    /sudosrv               <------ iscsi block d=
evice
sr0           1024M
vda             64G
=E2=94=9C=E2=94=80vda1 ext4     63G /
=E2=94=9C=E2=94=80vda2           1K
=E2=94=94=E2=94=80vda5 swap    975M [SWAP]

#cat /etc/exports
/sudosrv        *(rw,sync,fsid=3D0,no_subtree_check,no_root_squash,pnfs)

On client:
root@ubuntu18_04_2:~# cat /proc/partitions
major minor  #blocks  name

  11        0    1048575 sr0
 252        0   67108864 vda
 252        1   66107392 vda1
 252        2          1 vda2
 252        5     998400 vda5
   8        0    1048576 sda

root@ubuntu18_04_2:~# cat /proc/self/mountstats
device 192.168.122.92:/ mounted on /mnt with fstype nfs4 statvers=3D1.1
...
nfsv4:  bm0=3D0xfdffbfff,bm1=3D0x40f9be3e,bm2=3D0x803,acl=3D0x3,sessions,pn=
fs=3DLAYOUT_SCSI

blkmapd and blocklayoutdriver loaded on the client
root@ubuntu18_04_2:~# ps aux | grep blk
root      2485  0.0  0.0  23920   176 ?        Ss   21:25   0:00
/usr/sbin/blkmapd

-- packet exchange between MDS and client.
   94 2019-03-07 21:31:18.480733 192.168.122.83 =E2=86=92 192.168.122.92 NF=
S
234 V4 Call GETDEVINFO
   95 2019-03-07 21:31:18.483495 192.168.122.92 =E2=86=92 192.168.122.83 NF=
S
158 V4 Reply (Call In 94) GETDEVINFO Status: NFS4ERR_INVAL
   96 2019-03-07 21:31:18.483878 192.168.122.83 =E2=86=92 192.168.122.92 NF=
S
282 V4 Call LAYOUTRETURN
   98 2019-03-07 21:31:18.483935 192.168.122.83 =E2=86=92 192.168.122.92 NF=
S
1478 V4 Call WRITE StateID: 0xcaae Offset: 0 Len: 4096
  100 2019-03-07 21:31:18.484204 192.168.122.92 =E2=86=92 192.168.122.83 NF=
S
170 V4 Reply (Call In 96) LAYOUTRETURN
  102 2019-03-07 21:31:18.528822 192.168.122.92 =E2=86=92 192.168.122.83 NF=
S
246 V4 Reply (Call In 98) WRITE
