Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:35000 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933132AbcLBOXb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2016 09:23:31 -0500
Received: by mail-qt0-f181.google.com with SMTP id c47so252976618qtc.2
        for <linux-nfs@vger.kernel.org>; Fri, 02 Dec 2016 06:23:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161202134638.4ghyb5wnnwata4ec@ics.muni.cz>
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz> <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
 <20161129184843.jrwbnytggrz6kdir@ics.muni.cz> <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
 <20161202114134.rvzqptnsqo3odxay@ics.muni.cz> <CAHVgHyU6LQak3O4ybR0H3whWCKUdfz2bxLvEGi9uFM1EX+e=Eg@mail.gmail.com>
 <20161202134638.4ghyb5wnnwata4ec@ics.muni.cz>
From: Andy Adamson <androsadamson@gmail.com>
Date: Fri, 2 Dec 2016 09:23:30 -0500
Message-ID: <CAHVgHyVWqNZv55dH3hhZ-0XDsd4c79OW_R6Ze02uhv-nqePpPQ@mail.gmail.com>
Subject: Fwd: RFC rpc.gssd enhancement
To: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

'cc the kerne list


-->Andy

On Fri, Dec 2, 2016 at 8:46 AM, Lukas Hejtmanek <xhejtman@gmail.com> wrote:
> On Fri, Dec 02, 2016 at 08:26:33AM -0500, Andy Adamson wrote:
>> That is not saying much. AUTH_SYS is _completely_ insecure. RPCSEC_GSS
>> with Kerberos is as secure as we get. Watering down Kerberos security
>> is silly. AFAICS, the only reason kinit of the user to re-establish
>> the Kerberos GSS context for NFS is the fact that the result of the
>> kinit is stored in NFS under Kerberos. That is a silly design!
>
> no, it is not, that is misunderstanding. kinit does not store anything in
> $HOME. Tickets are in /tmp (or maybe in $TMPDIR). However, knit searches =
for
> ~/.krb5/config at start and ~ is Kerberzied. Maybe silly design, but not =
mine
> but kerberos guys (MIT ones).

So, how does sshd allow the user to kinit on login?
Here are the steps to allow the user to access the NFS kerberized share:

1) machine has NFS mounted /home using kerberos authentication
2) user logs in, sshd creates krb ticket ($HOME/.k5login needs to be world
readable to allow kerberized access, e.g., using kerberos ticket)

Why does the user kinit (e.g. the user logs in) allow sshd to create
the initial krb ticket in $HOME/<whatever> yet the user kinit to renew
said krb ticket fail?

>
>>
>> >> True.
>> >
>> > So, I was asking, if I provide such patch, will it be accepted into ma=
inline
>> > nfs-utils?
>>
>> It shouldn't be. I strongly object. Just to be clear, here is what you
>> are asking:
>>
>> >>So, I think in this case, I would like to see rpc.gssd uses host keyta=
b while
>> >>user's ticket is not available, which maps to nobody/nogroup,

Maybe the NFS client machine key maps to nobody/nogroup in your
environment, but it does not in others. Other environments can (and
do) map the machine cred to any UID they want - including root.

user ssh's into the NFS client machine.


>>  but kinit should succeed.
>>
>> If the above were implemented - an attacker that has rooted the  NFS
>> client machine, or got control of gssd in some way - which means the
>> attacker has the NFS client machine key, can kinit as _any_ user at
>> _any_ time and access _any_ users kerberos NFS share accessible from
>> the client machine.
>>
>> That is a huge security hole and a very large security degradation!!
>
> again, huge misunderstanding. The thing I want is that user without his/h=
er
> ticket is mapped to nobody/nogroup identity.

In your environment, UID 0 on the client machine (the machine
credential in the host keytab) is mapped to nobody/nobody when
accessing the NFS server.



> I do not want any shortcut to
> fake user ticket or something. I just want the user without ticket to be
> allowed access kerberized home with nfs/$HOSTNAME identity, i.e., the sam=
e
> identity as root user uses. So potential attacker gets nothing more than
> already has if he escalates root access. And yes, the attacker has limite=
d
> access to kerberized share if only user account is compromised. But this =
is
> the decision of NFS client machine administrator. If root access is
> compromised (still, it is gssd specific and nothing prevents the attacker=
 to
> build such patch on his own), there is nothing that attackers get.
>
> --
> Luk=C3=A1=C5=A1 Hejtm=C3=A1nek
