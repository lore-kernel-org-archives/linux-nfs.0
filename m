Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:36826 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab2EMNh7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 May 2012 09:37:59 -0400
Received: by vbbff1 with SMTP id ff1so4091840vbb.19
        for <linux-nfs@vger.kernel.org>; Sun, 13 May 2012 06:37:58 -0700 (PDT)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <4FAF9E19.4060802@tonian.com>
References: <4FAF9E19.4060802@tonian.com>
Date: Sun, 13 May 2012 15:37:58 +0200
Message-ID: <CAGue13rFG30EzmQX7sfYA_ouPBxaUu1Xs8sb1ee4fBMtaufKpA@mail.gmail.com>
Subject: Re: nfs v4.1 client without pNFS
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Lior <lior@tonian.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Lior,

you can blacklist the layout driver in /etc/modprobe.d/nfsv41.conf

blacklist nfs_layout_nfsv41_files


Tigran.
On Sun, May 13, 2012 at 1:42 PM, Lior <lior@tonian.com> wrote:
> Hi Trond,
>
> The rfc 5661 states that pNFS is an optional feature.
> Is there currently an intent to implement some sort of an option (module
> option ,or mount option) to run the NFSv4.1 client without pNFS
> functionality?
>
> Thanks,
>  Lior K.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
