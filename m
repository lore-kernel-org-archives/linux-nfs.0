Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33821 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932933AbcLHV6T (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2016 16:58:19 -0500
Received: by mail-io0-f172.google.com with SMTP id p42so28143418ioo.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Dec 2016 13:58:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEt3kCD-CJAFAL8E=eHNG0tk1gt84L35HU7nQMHg2_zFw@mail.gmail.com>
References: <20161129184843.jrwbnytggrz6kdir@ics.muni.cz> <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
 <20161202114134.rvzqptnsqo3odxay@ics.muni.cz> <CAHVgHyU6LQak3O4ybR0H3whWCKUdfz2bxLvEGi9uFM1EX+e=Eg@mail.gmail.com>
 <20161202134638.4ghyb5wnnwata4ec@ics.muni.cz> <CAHVgHyVWqNZv55dH3hhZ-0XDsd4c79OW_R6Ze02uhv-nqePpPQ@mail.gmail.com>
 <20161202142847.vyhp6ogtu6gvuabf@ics.muni.cz> <CAHVgHyW6fo1b2LSjxq73n7wQkR9r0JEvwzxHdb3X9p+gSpLQ1Q@mail.gmail.com>
 <20161208123616.nndod3snzoeyr565@ics.muni.cz> <CAN-5tyGCTkqX7qmR+kjsGTtjqjMH6-PJ4VXWnP0+ruXzz5B+Cg@mail.gmail.com>
 <20161208212238.ctyshbcpz7afzrxv@ics.muni.cz> <CAN-5tyEt3kCD-CJAFAL8E=eHNG0tk1gt84L35HU7nQMHg2_zFw@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 8 Dec 2016 16:58:18 -0500
Message-ID: <CAN-5tyEUoqtLVERwE2mFYLDhbPsX5X=OTCOr1Jo24u7zTkftpA@mail.gmail.com>
Subject: Re: Fwd: RFC rpc.gssd enhancement
To: Lukas Hejtmanek <xhejtman@gmail.com>
Cc: Andy Adamson <androsadamson@gmail.com>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 8, 2016 at 4:50 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Thu, Dec 8, 2016 at 4:22 PM, Lukas Hejtmanek <xhejtman@gmail.com> wrote:
>> On Thu, Dec 08, 2016 at 04:11:38PM -0500, Olga Kornievskaia wrote:
>>> Why is "kinit" accessing ~/.krb5/config? Typically kinit will only
>>> access /etc/krb5.conf.
>>>
>>> You are describing a catch-22 system. You want to create credentials
>>> but to create credentials you need to access a file that is protected
>>> by the credentials. This is a badly designed setup.
>>>
>>> kinit normally does not require access into something that is
>>> protected by credentials gotten by kinit.
>>>
>>> Your solution is to provide your user with "kinit" that does not
>>> access ~/.krb5/config. Please describe the need for that file and why
>>> it can't be satisfied using machine global /etc/krb5.conf.
>>
>> debian heimdal 1.6~rc2+dfsg-9  opens ~/.krb5/config and ~/.rnd files.
>> dunno why.
>>
>> MIT implementation does not seem to access $HOME.
>
> When you say "MIT implementation does not seem to access $HOME", do
> you mean you've build kinit from MIT source and it works? If so, then
> solution seems to be to bug debian folks to investigate what happened
> to their kinit?
> For instance RHEL/CentOS 7 had an issue where there patched OpenSSH
> looked at .k5login file where normal ssh didn't and caused problems:
> https://bugzilla.redhat.com/show_bug.cgi?id=1328243
>
> I think that might be related to your other complaint with using ssh
> keys to ssh. But at the same time I can see that what's going on here
> is again somewhat un-kosher. If you placed .authorized_key under
> something that only user with credentials can access, then you can't
> get to it without having though credentials. You have mentioned that
> "authorized_key" are readable but typically ~/.ssh had 700 permission
> so sshd can't get to reading "authorized_keys" file.
>
> To summarize: i suggest that you check that if an upstream kinit (from
> MIT) and upstream openssh have the problems you are describing.

Sorry you said debian heimdal not MIT. If MIT works, I suggest
bringing this issue up on the heimdal kerberos mailing list and
describe the problem there.
