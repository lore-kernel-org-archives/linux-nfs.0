Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:32870 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037Ab0I2OVK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 10:21:10 -0400
Received: by pvg2 with SMTP id 2so185686pvg.19
        for <linux-nfs@vger.kernel.org>; Wed, 29 Sep 2010 07:21:10 -0700 (PDT)
In-Reply-To: <D4AFE98FB48D2F4CBFEACD015C9642DF026628@sha2122.hamburg.rwedea.de>
References: <D4AFE98FB48D2F4CBFEACD015C9642DF026628@sha2122.hamburg.rwedea.de>
Date: Wed, 29 Sep 2010 10:21:06 -0400
Message-ID: <AANLkTimHnNCaQrj2T4vuC8m3R_S8oqc9o6zQBW_GOGoo@mail.gmail.com>
Subject: Re: NFS4 / GSS: Problem with users accessing the mounted directories
 (with root, everything ist okay)
From: Kevin Coffman <kwc@citi.umich.edu>
To: "Beyersdorf, Wolfgang" <Wolfgang.Beyersdorf.Fa.Kontraktor@rwedea.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 29, 2010 at 5:02 AM, Beyersdorf, Wolfgang
<Wolfgang.Beyersdorf.Fa.Kontraktor@rwedea.com> wrote:
>
>
>
> Dear all,
>
> I got NFS4 with GSS running on CentOS 5. Everything is okay, all TGTs are okay and is working fine for the user ROOT.
>
> When I change to an other user, I got a permission denied, when I try to access the dierctory (e.g. ls -la)
>
> Here is the /var/log/messages part for this access (with full debugging on ndf, ndfs and rcp):
>
> Sep 29 10:11:59 sha9013 rpc.gssd[1645]: creating context with server nfs@sha9012.hamburg.rwedea.de                      <================================== system ist wating for 25 seconds
> Sep 29 10:12:23 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
> Sep 29 10:12:23 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de

> [ ... ]

> Sep 29 10:12:23 sha9013 rpc.gssd[1645]: creating context with server nfs@sha9012.hamburg.rwedea.de
> Sep 29 10:12:48 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
> Sep 29 10:12:48 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
>
> A  klist gives the following result:
> ========================

What does "klist -e" show?

>
> On the server, there is nothing inside the /var/log/messages
>

I assume there is output from svcgssd on the server when root accesses it?

The 25-second pauses sound as if there is an error of some kind on the
server and it is dropping the request rather than replying.  Perhaps a
network trace would reveal something.

K.C.
