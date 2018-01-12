Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:37552 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965156AbeALVa0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jan 2018 16:30:26 -0500
Received: by mail-it0-f50.google.com with SMTP id d137so10867270itc.2
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jan 2018 13:30:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <C9EF8404-FAED-4C62-9487-43D42141FD92@oracle.com>
References: <20180110004920.11100-1-gjover@sipwise.com> <49E44F63-42CF-4BF8-91E0-F89945D7CFE6@oracle.com>
 <20180112180528.GA9479@thunder.hadrons.org> <BB34439C-4BC6-46AE-B2E8-45E5F7396F21@oracle.com>
 <20180112211219.GA17573@suse.de> <C9EF8404-FAED-4C62-9487-43D42141FD92@oracle.com>
From: Matt Benjamin <mbenjami@redhat.com>
Date: Fri, 12 Jan 2018 16:30:24 -0500
Message-ID: <CAKOnarmcrHwZevdCp_DA7qfvFycMJ6KBuQoZqQYRDp6ppQUxYg@mail.gmail.com>
Subject: Re: [Libtirpc-devel] [PATCH] Do not bind to reserved ports registered
 in /etc/services
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Thorsten Kukuk <kukuk@suse.de>, Guillem Jover <gjover@sipwise.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On Fri, Jan 12, 2018 at 4:14 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

>>
>> openSUSE is removing sunrpc from glibc, Fedora seems to be removing
>> sunrpc from glibc, so it's only a matter of time when libtirpc is the
>> only RPC implementation used on Linux.
>
> There are other RPC implementations, for example:
>
>  - The nonstandard TI-RPC library used internally by Ganesha
>

The current idea behind libntirpc is that it has no intent, and
provides no trivial ability, to serve as the ONC RPC implementation
for any Linux application services.  It is, in other words, a
3rd-party component from the Linux system point of view.

Matt

>  - The RPC librar(ies) buried in Kerberos implementations
>
> So there's more to do than simply removing the one in glibc,
> unfortunately.

>
>
> --
> Chuck Lever


-- 

Matt Benjamin
Red Hat, Inc.
315 West Huron Street, Suite 140A
Ann Arbor, Michigan 48103

http://www.redhat.com/en/technologies/storage

tel.  734-821-5101
fax.  734-769-8938
cel.  734-216-5309
