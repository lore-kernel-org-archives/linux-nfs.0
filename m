Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:32990 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932110AbcLHNkG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2016 08:40:06 -0500
Received: by mail-qt0-f182.google.com with SMTP id p16so410597453qta.0
        for <linux-nfs@vger.kernel.org>; Thu, 08 Dec 2016 05:40:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161208132321.zafoouotkn2ycupn@ics.muni.cz>
References: <20161129184843.jrwbnytggrz6kdir@ics.muni.cz> <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
 <20161202114134.rvzqptnsqo3odxay@ics.muni.cz> <CAHVgHyU6LQak3O4ybR0H3whWCKUdfz2bxLvEGi9uFM1EX+e=Eg@mail.gmail.com>
 <20161202134638.4ghyb5wnnwata4ec@ics.muni.cz> <CAHVgHyVWqNZv55dH3hhZ-0XDsd4c79OW_R6Ze02uhv-nqePpPQ@mail.gmail.com>
 <20161202142847.vyhp6ogtu6gvuabf@ics.muni.cz> <CAHVgHyW6fo1b2LSjxq73n7wQkR9r0JEvwzxHdb3X9p+gSpLQ1Q@mail.gmail.com>
 <20161208123616.nndod3snzoeyr565@ics.muni.cz> <CAHVgHyWTeJ08T+ZovckLuLchx3w+mHu=bYqRcgu-pY5K=+JASA@mail.gmail.com>
 <20161208132321.zafoouotkn2ycupn@ics.muni.cz>
From: Andy Adamson <androsadamson@gmail.com>
Date: Thu, 8 Dec 2016 08:40:04 -0500
Message-ID: <CAHVgHyXZFZSicnbskJAaE7rULXm8m6OScR62AUuyXRBsP=mx+w@mail.gmail.com>
Subject: Re: Fwd: RFC rpc.gssd enhancement
To: Lukas Hejtmanek <xhejtman@gmail.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 8, 2016 at 8:23 AM, Lukas Hejtmanek <xhejtman@gmail.com> wrote:
> On Thu, Dec 08, 2016 at 08:18:02AM -0500, Andy Adamson wrote:
>> On Thu, Dec 8, 2016 at 7:36 AM, Lukas Hejtmanek <xhejtman@gmail.com> wro=
te:
>> > This discussion seems to be a bit fubar. So I start over again.
>> >
>> > I see three problems if $HOME is Kerberized NFS volume, I will call th=
is NFS
>> > client machine.
>> >
>> > 1) user logs via SSH to the NFS client machine using GSS API, i.e., th=
e user
>> >    has a Kerberos ticket.
>>
>> Did the user use kinit -f (to obtain a forwardable ticket)?
>>
>> Do you enable credential forwarding? e.g. does the .ssh/config file cont=
ain
>>
>> GSSAPIDelegateCredentials yes
>
> yes, but it does not help, the ticket is recreated bit later during log o=
n
> process.
>
>> Yes. Isn't this the issue that forwardable kerberos tickets and ssh
>> with GSSAPI is designed to solve?
>>
>> Why does the user want to login to the NFS client machine using the
>> ssh public key and not kinit -f and use forwardable tickets? Or have I
>> misunderstood.....
>
> well, for some reason for sshfs, user does not want to play with renewabl=
e
> ticket,

do you mean forwardable ticket?

> he wants just public key. But yes, instead of ssh public key, one can
> use forwardable ticket but those needs to be recreated/refreshed (we have
> limit for ticket duration 1 day, 7 days renewable).

BTW: All kerberos tickets need to be refreshed/renewed. No exceptions :)

Wait. The user  is willing to ssh into the NFS client machine using
the ssh public key and the type kinit and enter a password, but not
willing to kinit -f enter a password and then ssh into the NFS client
machine using GSSAPI an forwardable tickets? Do I have this right?

-->Andy

>
> --
> Luk=C3=A1=C5=A1 Hejtm=C3=A1nek
