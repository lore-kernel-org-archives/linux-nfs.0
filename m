Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:34664 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759727AbcLBPJ1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2016 10:09:27 -0500
Received: by mail-qk0-f170.google.com with SMTP id q130so93901422qke.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Dec 2016 07:09:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161202142847.vyhp6ogtu6gvuabf@ics.muni.cz>
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz> <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
 <20161129184843.jrwbnytggrz6kdir@ics.muni.cz> <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
 <20161202114134.rvzqptnsqo3odxay@ics.muni.cz> <CAHVgHyU6LQak3O4ybR0H3whWCKUdfz2bxLvEGi9uFM1EX+e=Eg@mail.gmail.com>
 <20161202134638.4ghyb5wnnwata4ec@ics.muni.cz> <CAHVgHyVWqNZv55dH3hhZ-0XDsd4c79OW_R6Ze02uhv-nqePpPQ@mail.gmail.com>
 <20161202142847.vyhp6ogtu6gvuabf@ics.muni.cz>
From: Andy Adamson <androsadamson@gmail.com>
Date: Fri, 2 Dec 2016 10:09:25 -0500
Message-ID: <CAHVgHyW6fo1b2LSjxq73n7wQkR9r0JEvwzxHdb3X9p+gSpLQ1Q@mail.gmail.com>
Subject: Re: Fwd: RFC rpc.gssd enhancement
To: Lukas Hejtmanek <xhejtman@gmail.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 2, 2016 at 9:28 AM, Lukas Hejtmanek <xhejtman@gmail.com> wrote:
> On Fri, Dec 02, 2016 at 09:23:30AM -0500, Andy Adamson wrote:
>> In your environment, UID 0 on the client machine (the machine
>> credential in the host keytab) is mapped to nobody/nobody when
>> accessing the NFS server
>
> well, ok, and this is what I want for users without kerberos tickets. Map=
 them
> to nobody/nogroup instead of error EPERM or EKEYEXPIRED. And I want this =
as an
> option for administator of NFS client machine.


>1) machine has NFS mounted /home using kerberos authentication

OK

> 2) user logs in,

You mean,  user ssh's into the NFS client machine and then runs kinit?
Or does the user run kinit locally and then use ssh to forward the
kerberos credentials?

 >sshd creates krb ticket ($HOME/.k5login

Why do you use .k5login?

from https://web.mit.edu/kerberos/krb5-1.13/doc/user/user_config/k5login.ht=
ml

The .k5login file, which resides in a user=E2=80=99s home directory, contai=
ns
a list of the Kerberos principals. Anyone with valid tickets for a
principal in the file is allowed host access with the UID of the user
in whose home directory the file resides. One common use is to place a
.k5login file in root=E2=80=99s home directory, thereby granting system
administrators remote root access to the host via Kerberos.

EXAMPLES

Suppose the user alice had a .k5login file in her home directory
containing just the following line:

bob@FOOBAR.ORG

This would allow bob to use Kerberos network applications, such as
ssh(1), to access alice=E2=80=98s account, using bob=E2=80=98s Kerberos tic=
kets. In a
default configuration (with k5login_authoritative set to true in
krb5.conf), this .k5login file would not let alice use those network
applications to access her account, since she is not listed! With no
.k5login file, or with k5login_authoritative set to false, a default
rule would permit the principal alice in the machine=E2=80=99s default real=
m
to access the alice account.


>needs to be world
>readable to allow kerberized access, e.g., using kerberos ticket)

1) Please explain what use the .k5login is in your environment.

2) IIUC only the initial ssh access works - the one that creates the
$HOME/.k5login. All other accesses fail?

3) you mentioned that it's not ~/.k5login but ~/.krb5/config that is
trying to be accessed. I can't find any doc on ~/.krb5/config. Is it
just the replacement for .k5login?

>ok, I did more testing. It seems that kinit does not search ~/.k5login but
>~/.krb5/config.

-->Andy


>
> --
> Luk=C3=A1=C5=A1 Hejtm=C3=A1nek
