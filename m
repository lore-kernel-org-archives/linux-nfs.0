Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34261 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750827AbcLHNSE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2016 08:18:04 -0500
Received: by mail-qk0-f181.google.com with SMTP id q130so261364005qke.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Dec 2016 05:18:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161208123616.nndod3snzoeyr565@ics.muni.cz>
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz> <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
 <20161129184843.jrwbnytggrz6kdir@ics.muni.cz> <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
 <20161202114134.rvzqptnsqo3odxay@ics.muni.cz> <CAHVgHyU6LQak3O4ybR0H3whWCKUdfz2bxLvEGi9uFM1EX+e=Eg@mail.gmail.com>
 <20161202134638.4ghyb5wnnwata4ec@ics.muni.cz> <CAHVgHyVWqNZv55dH3hhZ-0XDsd4c79OW_R6Ze02uhv-nqePpPQ@mail.gmail.com>
 <20161202142847.vyhp6ogtu6gvuabf@ics.muni.cz> <CAHVgHyW6fo1b2LSjxq73n7wQkR9r0JEvwzxHdb3X9p+gSpLQ1Q@mail.gmail.com>
 <20161208123616.nndod3snzoeyr565@ics.muni.cz>
From: Andy Adamson <androsadamson@gmail.com>
Date: Thu, 8 Dec 2016 08:18:02 -0500
Message-ID: <CAHVgHyWTeJ08T+ZovckLuLchx3w+mHu=bYqRcgu-pY5K=+JASA@mail.gmail.com>
Subject: Re: Fwd: RFC rpc.gssd enhancement
To: Lukas Hejtmanek <xhejtman@gmail.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 8, 2016 at 7:36 AM, Lukas Hejtmanek <xhejtman@gmail.com> wrote:
> This discussion seems to be a bit fubar. So I start over again.
>
> I see three problems if $HOME is Kerberized NFS volume, I will call this =
NFS
> client machine.
>
> 1) user logs via SSH to the NFS client machine using GSS API, i.e., the u=
ser
>    has a Kerberos ticket.

Did the user use kinit -f (to obtain a forwardable ticket)?

Do you enable credential forwarding? e.g. does the .ssh/config file contain

GSSAPIDelegateCredentials yes

>   SSHD on the NFS client machine has to access
>    ~/.k5login under root identity (usually host identity). User has to gr=
ant
>    access to such identity to his/her $HOME and .k5login in there.
>    Older version of Kerberos denied access if ~/.k5login had different
>    permision than 0600.
>
> 2) user logs via SSH to the NFS client machine using password.
> He/she stays
>    logged in, Kerberos ticket expires. Issuing kinit returns an error I'v=
e
>    already sent, because kinit wants to read ~/.krb5/config file and gets
>    EKEYEXPIRED. Kinit does not deal with such an error, it understand oln=
y
>    EPERM error. New ticket cannot be created until user deletes ticket fr=
om
>    TMPDIR (rm, not kdestroy as it does not work either).
>
> 3) user wants to log via SSH to the NFS client machine using ssh public k=
ey.
>    This cannot be done as ~/.ssh/authorized_keys is accessed by SSHD unde=
r
>    user context (not root context), so EPERM is returned even if user gra=
nts
>    access to read ~/.ssh/authorized_keys to anyone.

Yes. Isn't this the issue that forwardable kerberos tickets and ssh
with GSSAPI is designed to solve?

Why does the user want to login to the NFS client machine using the
ssh public key and not kinit -f and use forwardable tickets? Or have I
misunderstood.....

-->Andy
>
> While nothing can be done ad 1). My proposed extension of rpc.gssd would =
solve
> ad 2) and ad 3). As this should be purely rpc.gssd patch, possible attack=
er
> with escalated root access is out of question because the attacker can re=
place
> rpc.gssd on his own. And also in this case, decision whether user gets
> EKEYEXPIRED/EPERM or granted access as some particular identity is desici=
on of
> the administator of the NFS client machine.
>
> --
> Luk=C3=A1=C5=A1 Hejtm=C3=A1nek
