Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:37851 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933129AbcHaTl1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Aug 2016 15:41:27 -0400
Received: by mail-it0-f50.google.com with SMTP id e124so27829350ith.0
        for <linux-nfs@vger.kernel.org>; Wed, 31 Aug 2016 12:41:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJvUf-BwEKes-C-D3xxXyYEV9bTFpQ6JTn1iEwknQ4FwKhxQmw@mail.gmail.com>
References: <CAJvUf-BsCHCQZkWu8iKMbQTESANfrLjtH8uMqtzdUNcj1SmJ9Q@mail.gmail.com>
 <CAN-5tyHfoFN8XAnFpY+NZFeEg_wHCVe7FOdLgt3y3+W1jkXnhw@mail.gmail.com> <CAJvUf-BwEKes-C-D3xxXyYEV9bTFpQ6JTn1iEwknQ4FwKhxQmw@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 31 Aug 2016 15:41:26 -0400
Message-ID: <CAN-5tyFhPkrgvcrJ_2n20sFkczaVrf1YC5WR9_b5W31E+a7thw@mail.gmail.com>
Subject: Re: gss context cache and nfsv4
To: Matt Garman <matthew.garman@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 31, 2016 at 3:10 PM, Matt Garman <matthew.garman@gmail.com> wrote:
> On Wed, Aug 31, 2016 at 1:40 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> The lifetime (expressed in seconds) of the gss context is determined
>> to be the end lifetime of the service ticket  - time now.
>
> Based on a simple experiment, I don't think this is true (or I'm
> mis-understanding your explanation).  What I did is log into a host
> that uses NFSv4 sec=krb5p home directories.  klist shows the service
> ticket for nfs as not expiring until October 27, 2016 (I have all
> ticket lifetimes in Kerberos configured for 70 days).
>
> Now, I do a "kdestroy" and make a note of the time.  I then run a
> simple loop like this:
>
> # while [ 1 ] ; do date ; ls ; sleep 1m ; done
>
> Twice now I've done this experiment on two different hosts.  After
> almost exactly an hour, I start getting "Permission denied".
>
> But from your description above, I would expect that I shouldn't see
> "Permission denied" until the end of October, right?

I should have asked for what distro/nfs-utils are you using?

In the RHEL/Fedora nfs-utils distros, lifetime of the context is
gotten from gss_inquire_context() call from the gss krb5 api. In
krb5_gss_inquire_context() in krb5 source code in
src/lib/gssapi/krb5/inq_context.c it's set to what I have set before.

A server can choose to expire the context at any time by returning gss
context error and force the client to create the new security context.
What server are you going against? A network trace would be helpful to
check to see if the server is returning such error.
