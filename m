Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:43397 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753426AbdKXL5Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Nov 2017 06:57:25 -0500
Received: by mail-wm0-f48.google.com with SMTP id x63so21956220wmf.2
        for <linux-nfs@vger.kernel.org>; Fri, 24 Nov 2017 03:57:25 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: How to get NFS user list
From: =?utf-8?Q?=C3=96zkan_G=C3=B6ksu?= <ozkan.goksu@usishi.com>
In-Reply-To: <20171123131327.1aa66e49@harpe.intellique.com>
Date: Fri, 24 Nov 2017 14:58:23 +0200
Cc: linux-nfs@vger.kernel.org
Message-Id: <4C72B57D-F4C3-499B-8852-3C677F6C1DDA@usishi.com>
References: <296856FF-A18F-47EB-96AF-5C0E6C9BB5E1@usishi.com> <20171123131327.1aa66e49@harpe.intellique.com>
To: Emmanuel Florac <eflorac@intellique.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Emmanuel.

Thank you for reply.
In the end I need information about NFS to show on my Gui.
But NFS gives me nothing.
At least we need to see who and where is connected, how much io the nfs =
server is using realtime.

I can see who is connected with "netstat -an | grep host:.2049"
I can get which ip using which share with showmount But showmount =
command shows me something else maybe =E2=80=9Csamba usage" because i =
can't see "10.1.60.219" in there.

Fo example:=20
netstat -an | grep 10.1.60.4:2049
tcp        0      0 10.1.60.4:2049          10.1.60.219:776         =
ESTABLISHED
tcp        0      0 10.1.60.4:2049          192.168.10.31:764       =
ESTABLISHED

cat /var/lib/nfs/rmtab
10.1.60.73:/clspool/winnfs:0x00000001
10.1.60.70:/clspool/winnfs2:0x00000001
10.1.60.70:/clspool/winnfs:0x00000003
192.168.10.7:/clspool/nfstest:0x00000004
10.2.60.128:/clspool/nfstest:0x00000001


> 23 Kas 2017 tarihinde 14:13 saatinde, Emmanuel Florac =
<eflorac@intellique.com> =C5=9Funlar=C4=B1 yazd=C4=B1:
>=20
> Le Wed, 22 Nov 2017 16:31:43 +0200
> =C3=96zkan G=C3=B6ksu <ozkan.goksu@usishi.com> =C3=A9crivait:
>=20
>> I want to get NFS user list (client list) like "smbstatus"
>> I want to see which user & ip is using which share and when =
connected.
>> I want to kill a nfs user.
>> I want to log what an user is doing like "Create, modify, delete".
>>=20
>> In the end; I want to manage nfs users. There is not enough
>> information and tools about this problem.
>>=20
>> How you manage your nfs server?
>=20
> Traditional tools for NFS monitoring are showmount, nfsstat and
> nfswatch. Common other tools are nfsiostats and mountstats (on the
> client). Unfortunately, AFAIK there is no single tools providing all
> needed information, and nothing that compares to "smbstatus", i.e.
> connected clients and opened files.
>=20
> --=20
> =
------------------------------------------------------------------------
> Emmanuel Florac     |   Direction technique
>                    |   Intellique
>                    |	<eflorac@intellique.com>
>                    |   +33 1 78 94 84 02
> =
------------------------------------------------------------------------

