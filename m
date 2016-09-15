Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:26634 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752207AbcIOXAx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2016 19:00:53 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Ben Greear <greearb@candelatech.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: nfs broken on Fedora-24, 32-bit?
Date: Thu, 15 Sep 2016 23:00:47 +0000
Message-ID: <DE7D6150-4E55-4940-8BD8-3FF2484E3313@primarydata.com>
References: <de68a5b5-fa21-1ca4-68e9-feeea009e6d3@candelatech.com>
In-Reply-To: <de68a5b5-fa21-1ca4-68e9-feeea009e6d3@candelatech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

> On Sep 15, 2016, at 18:32, Ben Greear <greearb@candelatech.com> wrote:
>=20
> I have a Fedora-24 machine mounting an NFS server running Fedora-13 (kern=
el 2.6.34.9-69.fc13.x86_64).
>=20
> F24 machine has this in /etc/fstab:
>=20
> 192.168.100.3:/mnt/d2 /mnt/d2                   nfs     nfsvers=3D3      =
 0 0
>=20
> When I copy a file from f24-32 to the F-13 machine, the file size is the =
same,
> but the file is corrupted on the file server.  I see a different md5sum e=
ach time.
>=20
> Various other systems (F21, F19, etc) can all copy to the F13 machine fin=
e.
>=20
> And, F24-64 machine can copy to the F13 machine fine.
>=20
> Anyone seen something similar?

Do you know if the corruption is happening on the read()s or on the write()=
s? Do you, for instance get the same corruption if you copy from a local fi=
le on the F-24 client to the server? ..or if you copy from a file on the se=
rver to a local directory on the F-24 client?

Cheers
  Trond

