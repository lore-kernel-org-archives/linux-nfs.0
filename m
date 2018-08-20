Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua1-f68.google.com ([209.85.222.68]:39065 "EHLO
        mail-ua1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726077AbeHTWqs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Aug 2018 18:46:48 -0400
Received: by mail-ua1-f68.google.com with SMTP id g18-v6so10420630uam.6
        for <linux-nfs@vger.kernel.org>; Mon, 20 Aug 2018 12:29:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1377475602.793145.1534528695060@email.1and1.com>
References: <1377475602.793145.1534528695060@email.1and1.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 20 Aug 2018 15:29:54 -0400
Message-ID: <CAN-5tyH=CB2KCJ+OEfQj0=AyJ8X1sOuAJhsf5nOaOe+ArL_f7A@mail.gmail.com>
Subject: Re: Linux NFS Client and NFS v4.1 Session Trunking
To: Ryan Covietz <ryan.covietz@metakrypt.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ryan,

Session trunking is only done for the pnfs servers. Since there isn't
an established trunking discovery mechanism for 4.1 meta data server,
no way to find where all the available IPs to trunk with, there is no
session trunking now.

How are you doing session trunking on VMware?

On Fri, Aug 17, 2018 at 1:58 PM, Ryan Covietz
<ryan.covietz@metakrypt.com> wrote:
> Greetings all,
>
> Apologies in advance if this mailing list is not the correct forum for my
> inquiry.
>
> Background:
> I've successfully tested NFS session trunking on the server side with Debian
> Stretch and the v4.17.8-1~bpo9+1 backports kernel, nfs-kernel-server v1:1.3.4-2.1, and using VMware ESXi 6.7.0 as a client (session trunking even works with bonded interfaces on the server side!).
> Unfortunately, I've had no luck with getting session trunking to work
> with the Linux NFS client (nfs-common version 1:1.3.4-2.1 on Debian) both on
> Debian Stretch and on Fedora 28 using the "mount -t nfs4 -o minorversion=1"
> options to mount an export multiple times over different interfaces / IPs.
>
> Documentation on the NFS session trunking feature seems to be sparse to non-existent, and the only tested client configuration I found was by Martin Houry a couple of years ago:
>
> https://marc.info/?l=linux-nfs&m=145570512215071&w=2
>
> ...not clear if the patches he tested were ever integrated into the Linux kernel though? I just wanted to inquire if the NFS v4.1 session trunking functionality has been integrated into the Linux NFS client yet?
>
> Any clarification or direction would be greatly appreciated.
>
> Thank you in advance and best regards,
>
> Ryan
