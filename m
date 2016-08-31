Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:36054 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752930AbcHaTK3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Aug 2016 15:10:29 -0400
Received: by mail-it0-f51.google.com with SMTP id i184so27059295itf.1
        for <linux-nfs@vger.kernel.org>; Wed, 31 Aug 2016 12:10:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHfoFN8XAnFpY+NZFeEg_wHCVe7FOdLgt3y3+W1jkXnhw@mail.gmail.com>
References: <CAJvUf-BsCHCQZkWu8iKMbQTESANfrLjtH8uMqtzdUNcj1SmJ9Q@mail.gmail.com>
 <CAN-5tyHfoFN8XAnFpY+NZFeEg_wHCVe7FOdLgt3y3+W1jkXnhw@mail.gmail.com>
From: Matt Garman <matthew.garman@gmail.com>
Date: Wed, 31 Aug 2016 14:10:28 -0500
Message-ID: <CAJvUf-BwEKes-C-D3xxXyYEV9bTFpQ6JTn1iEwknQ4FwKhxQmw@mail.gmail.com>
Subject: Re: gss context cache and nfsv4
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 31, 2016 at 1:40 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> The lifetime (expressed in seconds) of the gss context is determined
> to be the end lifetime of the service ticket  - time now.

Based on a simple experiment, I don't think this is true (or I'm
mis-understanding your explanation).  What I did is log into a host
that uses NFSv4 sec=krb5p home directories.  klist shows the service
ticket for nfs as not expiring until October 27, 2016 (I have all
ticket lifetimes in Kerberos configured for 70 days).

Now, I do a "kdestroy" and make a note of the time.  I then run a
simple loop like this:

# while [ 1 ] ; do date ; ls ; sleep 1m ; done

Twice now I've done this experiment on two different hosts.  After
almost exactly an hour, I start getting "Permission denied".

But from your description above, I would expect that I shouldn't see
"Permission denied" until the end of October, right?
