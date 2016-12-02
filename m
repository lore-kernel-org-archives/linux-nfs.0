Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:36346 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750862AbcLBOAr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2016 09:00:47 -0500
Received: by mail-qk0-f171.google.com with SMTP id n21so279345788qka.3
        for <linux-nfs@vger.kernel.org>; Fri, 02 Dec 2016 06:00:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHVgHyU6LQak3O4ybR0H3whWCKUdfz2bxLvEGi9uFM1EX+e=Eg@mail.gmail.com>
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz> <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
 <20161129184843.jrwbnytggrz6kdir@ics.muni.cz> <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
 <20161202114134.rvzqptnsqo3odxay@ics.muni.cz> <CAHVgHyU6LQak3O4ybR0H3whWCKUdfz2bxLvEGi9uFM1EX+e=Eg@mail.gmail.com>
From: Andy Adamson <androsadamson@gmail.com>
Date: Fri, 2 Dec 2016 09:00:44 -0500
Message-ID: <CAHVgHyU2QkfQMZ5DW+YtLokVSuYaXnUCP_MAPe5MLfxyHVpy5Q@mail.gmail.com>
Subject: Fwd: RFC rpc.gssd enhancement
To: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oops - forgot to 'cc the kernel list.

-->andy


---------- Forwarded message ----------
From: Andy Adamson <androsadamson@gmail.com>
Date: Fri, Dec 2, 2016 at 8:26 AM
Subject: Re: RFC rpc.gssd enhancement
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>


On Fri, Dec 2, 2016 at 6:41 AM, Lukas Hejtmanek <xhejtman@ics.muni.cz> wrot=
e:
> On Tue, Nov 29, 2016 at 02:28:10PM -0500, Steve Dickson wrote:
>> > maybe it is not considered secure, but it is still more secure to me t=
han
>> > using sec=3Dsys.

That is not saying much. AUTH_SYS is _completely_ insecure. RPCSEC_GSS
with Kerberos is as secure as we get. Watering down Kerberos security
is silly. AFAICS, the only reason kinit of the user to re-establish
the Kerberos GSS context for NFS is the fact that the result of the
kinit is stored in NFS under Kerberos. That is a silly design!

>> True.
>
> So, I was asking, if I provide such patch, will it be accepted into mainl=
ine
> nfs-utils?

It shouldn't be. I strongly object. Just to be clear, here is what you
are asking:

>>So, I think in this case, I would like to see rpc.gssd uses host keytab w=
hile
>>user's ticket is not available, which maps to nobody/nogroup, but kinit s=
hould succeed.

If the above were implemented - an attacker that has rooted the  NFS
client machine, or got control of gssd in some way - which means the
attacker has the NFS client machine key, can kinit as _any_ user at
_any_ time and access _any_ users kerberos NFS share accessible from
the client machine.

That is a huge security hole and a very large security degradation!!

In the current situation, rooting the NFS client machine only gives
access (with a lot of hacking) to the non-expired in-kernel GSS
contexts of active NFS users. Once the GSS context expires, the
attacker has nothing.

>
>> > the problem is, that kerberized home is problem for .k5login file and =
also for
>> > .ssh/authorized_keys. While the .k5login file is accessed with root co=
ntext
>> > (sshd), the authorized_keys is accessed with user context, so login vi=
a ssh
>> > pubkey is not possible at all.

That is no reason to degrade Kerberos security!

I don't get this:

Here are the steps to allow the user to access the NFS kerberized share:

1) machine has NFS mounted /home using kerberos authentication
2) user logs in, sshd creates krb ticket ($HOME/.k5login needs to be world
readable to allow kerberized access, e.g., using kerberos ticket)

Why does the user kinit (e.g. the user logs in) allow sshd to create
the initial krb ticket in $HOME/<whatever> yet the user kinit to renew
said krb ticket fail? That seems to be a silly design.


>> What would the .k5login look like and what would the principal look like=
?
>> My apologies but I'm not very familar with how sshd interacts with
>> the .k5login.
>
> ok, I did more testing. It seems that kinit does not search ~/.k5login bu=
t
> ~/.krb5/config.
>
> If NFS client gets permission denied, it is ok and kinit just creates a n=
ew
> ticket.

Huh? What kinit? The NFS client (using the machine key) uses a keytab
which means no kinit is required.

Using a keytab is one way to have renewable Kerberos credentials.

The correct way to solve your problem is with renewable tickets.

I suggest you read:

https://web.mit.edu/kerberos/krb5-1.13/doc/user/tkt_mgmt.html

which includes:

"Renewable tickets can be used to obtain new session keys without the
user entering their password again. A renewable ticket has two
expiration times. The first is the time at which this particular
ticket expires. The second is the latest possible expiration time for
any ticket issued based on this renewable ticket."

Or perhaps this from microsoft:

https://social.technet.microsoft.com/Forums/windowsserver/en-US/e0c6a401-16=
09-47c9-8f1c-6437b98bef2a/how-does-kerberos-ticket-or-tgt-get-renewed-or-re=
freshed?forum=3Dwinserversecurity

"When tickets are renewable, session keys are refreshed periodically
without issuing a completely new ticket. If Kerberos policy permits
renewable tickets, the KDC sets a RENEWABLE flag in every ticket it
issues and sets two expiration times in the ticket. One expiration
time limits the life of the current instance of the ticket; the second
expiration time sets a limit on the cumulative lifetime of all
instances of the ticket.

The expiration time for the current instance of the ticket is held in
the End Time field. As with non-renewable tickets, the value in the
End Time field equals the value in the Start Time field plus the value
of the maximum ticket life specified by Kerberos policy. A client
holding a renewable ticket must send it=E2=80=94presenting a fresh
authenticator as well=E2=80=94to the KDC for renewal before the end time is
reached. When the KDC receives a ticket for renewal, it checks the
value of a second expiration time held in the Renew Till field. This
value is set when the ticket is first issued. It equals the value in
the tickets Start Time field plus the value of the maximum cumulative
ticket life specified by Kerberos policy. When the KDC renews the
ticket, it checks to determine if the renew-till time has not yet
arrived. If it has not, the KDC issues a new instance of the ticket
with a later end time and a new session key.

This means that administrators can set Kerberos policy so that tickets
must be renewed at relatively short intervals=E2=80=94every day, for exampl=
e.
When tickets are renewed, a new session key is issued, minimizing the
value of a compromised key. Administrators can also set cumulative
ticket life for a relatively long period=E2=80=94one week or one month, for
example. At the end of that time, the ticket expires and is no longer
valid for renewal."

There are many ways to set this up.

https://linux.die.net/man/1/krenew

As Steve Dickson mentioned, Red Hat SSSD does ticket renewal

>
> However, if user has ticket that expired, NFS client returns EKEYEXPIRED
> instead of EPERM.

That is because the key has expired!!!

#define EKEYEXPIRED     127     /* Key has expired */

so EKEYEXPIRED is obviously the correct error!


> In such a case, kinit/kdestoy does not deal with this errno
> and returns:
> kinit: krb5_init_context failed: 127
> or
> kdestroy: krb5_init_context failed: 127
>
> if you do rm /tmp/krb5cc_`id -u`_*, EKEYEXPIRED is changed to EPERM and
> kinit/kdestroy works again.
>
>
> Colleague of me says that EKEYEPIRED should not be returned by NFS client=
 at
> all, EPERM should be always returned and he sees this as a bug in kernel =
code.

No! EKEYEXPIRED is used to signal the user that the only reason for
the failure is that the user's credentials have expired, and that the
user therefore needs to renew her credentials. EKEYEXPIRED is exactly
the error to return.

-->Andy


>
> --
> Luk=C3=A1=C5=A1 Hejtm=C3=A1nek
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
