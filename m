Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36271 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751203AbcK2UEj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 15:04:39 -0500
Received: by mail-io0-f179.google.com with SMTP id m5so172164117ioe.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2016 12:04:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz>
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 29 Nov 2016 15:04:37 -0500
Message-ID: <CAN-5tyGEsb=M3tVEfKs5L8N=um+y22O4zuyK6u6tO9LCGbe10w@mail.gmail.com>
Subject: Re: RFC rpc.gssd enhancement
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 28, 2016 at 1:37 PM, Lukas Hejtmanek <xhejtman@ics.muni.cz> wro=
te:
> Hello,
>
> would it be acceptable to add an option for rpc.gssd to use host keytab i=
f
> user's kerberos ticket is not available?
>
> Consider the following scenario:
> 1) machine has NFS mounted /home using kerberos authentication
> 2) user logs in, sshd creates krb ticket ($HOME/.k5login needs to be worl=
d
> readable to allow kerberized access, e.g., using kerberos ticket)
> 3) user stays logged in and krb ticket expires
> 4) kinit to renew ticket produces strange error because $HOME is not
> accessible and a new ticket is not created.

Why is kinit accessing something from $HOME. What distro are you using
to run kinit (or any other info to explain use of $HOME)?

I just ran kinit on RHEL7.2 and it nowhere does it read $HOME.

What I read here is that user has expired creds and is trying to
access a kerberized NFS file. The operation MUST fail, there is no way
around it. There shouldn't be any fixes that would allow for a user to
access files without credentials.

So in the environment where for whatever reason your kinit requires
read of $HOME, you must make sure credentials are refreshed before
they expire. Steve has mentioned that sssd takes on this
responsibility.

> So, I think in this case, I would like to see rpc.gssd uses host keytab w=
hile
> user's ticket is not available, which maps to nobody/nogroup, but kinit s=
hould
> succeed.
>
> Or are there any other options if one is using kerberized homes only?
>
> --
> Luk=C3=A1=C5=A1 Hejtm=C3=A1nek
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
