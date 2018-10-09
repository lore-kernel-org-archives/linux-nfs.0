Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41700 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726479AbeJIU1v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Oct 2018 16:27:51 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Language Lawyer" <language.lawyer@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel NFS client and Kerberos delegation
Date: Tue, 09 Oct 2018 09:11:07 -0400
Message-ID: <A418C8F8-0189-4959-9E29-862095728028@redhat.com>
In-Reply-To: <6369655a-a0b0-5c3c-7c68-b623a4270668@gmail.com>
References: <6369655a-a0b0-5c3c-7c68-b623a4270668@gmail.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8 Oct 2018, at 15:46, Language Lawyer wrote:

> Hi,
>
> AFAIU kernel NFS client keeps ID -> Name mapping in the "id_resolver"
> keyring.  Do I understand it correctly that with this hard mapping it is
> not possible for a service to access a kerberized NFS storage on behalf of
> some user using user's delegated (for example, with S4U2Self+S4U2Proxy)
> credentials?

The id_resolver keyring exists to translate kerberos principles to UID and
the reverse, but it doesn't really play in the mechanisms that you're
interested in.

I assume you want a particular process, like httpd, to have the kernel chose
which kerberos principle and thus which GSS context to use when sending RPC
to the NFS server.

The NFS client will choose the appropriate GSS context based on the fsuid of
the calling process, and then as long as the gssd daemon can find an
appropriate kerberos cache and establish a context everything will work
fine.  So, as long as your service changes its fsuid (like smbd does),
everything generally works.

If you want a process that doesn't change its fsuid to use a different GSS
context, you have to find a way to communicate which context, or credential
you want the kernel to choose.

Ben
