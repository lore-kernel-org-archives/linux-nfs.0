Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:37396 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751573AbcKBODt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Nov 2016 10:03:49 -0400
Received: by mail-it0-f41.google.com with SMTP id u205so38650034itc.0
        for <linux-nfs@vger.kernel.org>; Wed, 02 Nov 2016 07:03:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFhPkrgvcrJ_2n20sFkczaVrf1YC5WR9_b5W31E+a7thw@mail.gmail.com>
References: <CAJvUf-BsCHCQZkWu8iKMbQTESANfrLjtH8uMqtzdUNcj1SmJ9Q@mail.gmail.com>
 <CAN-5tyHfoFN8XAnFpY+NZFeEg_wHCVe7FOdLgt3y3+W1jkXnhw@mail.gmail.com>
 <CAJvUf-BwEKes-C-D3xxXyYEV9bTFpQ6JTn1iEwknQ4FwKhxQmw@mail.gmail.com> <CAN-5tyFhPkrgvcrJ_2n20sFkczaVrf1YC5WR9_b5W31E+a7thw@mail.gmail.com>
From: Matt Garman <matthew.garman@gmail.com>
Date: Wed, 2 Nov 2016 09:03:48 -0500
Message-ID: <CAJvUf-CMY=QNtYeLviRBDDtO-tdrGOcED=OHMS2cUOkfe_RB3Q@mail.gmail.com>
Subject: Re: gss context cache and nfsv4
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 31, 2016 at 2:41 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> I should have asked for what distro/nfs-utils are you using?
>
> In the RHEL/Fedora nfs-utils distros, lifetime of the context is
> gotten from gss_inquire_context() call from the gss krb5 api. In
> krb5_gss_inquire_context() in krb5 source code in
> src/lib/gssapi/krb5/inq_context.c it's set to what I have set before.
>
> A server can choose to expire the context at any time by returning gss
> context error and force the client to create the new security context.
> What server are you going against? A network trace would be helpful to
> check to see if the server is returning such error.

Bringing this thread back to life...

I am using CentOS (effectively same as RHEL) 6.5.  nfs-utils version
1.2.3-39.  All clients and servers are same OS version, same kernel,
same nfs-utils.

Just to be clear: in your suggestion of a network trace, do you mean
using something like tcpdump or wireshark to see exactly what is going
on between client and server?  Is it sufficient to do this while I am
seeing "permission denied" on the krb5p share?

Since I am using krb5p (not the 'p'), I believe all NFS traffic is
encrypted... so will I actually be able to see anything useful in the
packet capture?  Can you elaborate specifically on what I should look
for?

Lastly... as a workaround, can I use the "-t" parameter of rpc.gssd?
What if I set that value to be equivalent to be the same as our
Kerberos ticket lifetime?

Thank you,
Matt
