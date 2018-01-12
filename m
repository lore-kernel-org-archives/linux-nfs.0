Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:47344 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964844AbeALVPU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jan 2018 16:15:20 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [Libtirpc-devel] [PATCH] Do not bind to reserved ports registered
 in /etc/services
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180112211219.GA17573@suse.de>
Date: Fri, 12 Jan 2018 16:14:53 -0500
Cc: Guillem Jover <gjover@sipwise.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
Message-Id: <C9EF8404-FAED-4C62-9487-43D42141FD92@oracle.com>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <49E44F63-42CF-4BF8-91E0-F89945D7CFE6@oracle.com>
 <20180112180528.GA9479@thunder.hadrons.org>
 <BB34439C-4BC6-46AE-B2E8-45E5F7396F21@oracle.com>
 <20180112211219.GA17573@suse.de>
To: Thorsten Kukuk <kukuk@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 12, 2018, at 4:12 PM, Thorsten Kukuk <kukuk@suse.de> wrote:
>=20
> On Fri, Jan 12, Chuck Lever wrote:
>=20
>>> On Jan 12, 2018, at 1:05 PM, Guillem Jover <gjover@sipwise.com> =
wrote:
>=20
>>> [F] =
<https://sources.debian.org/src/glibc/2.26-3/debian/patches/any/local-bind=
resvport_blacklist.diff/>
>>>=20
>>> On the above Debian bug report, it was proposed to make libtirpc =
switch
>>> to use the libc bindresvport() implementation so that at least on =
those
>>> distributions where it is locally patched it would honor the
>>> /etc/bindresvport.blacklist file. The problem with this, is of =
course
>>> that it does not help any upstream code on any other non-patched =
system.
>>=20
>> The community issue here is that there have evolved, over time,
>> multiple RPC libraries with divergent capabilities. The only way
>> to truly address this confusion is to eliminate all but one of
>> them, which is far outside the scope of your bug fix. For now we
>> have to live with it.
>=20
> openSUSE is removing sunrpc from glibc, Fedora seems to be removing
> sunrpc from glibc, so it's only a matter of time when libtirpc is the
> only RPC implementation used on Linux.

There are other RPC implementations, for example:

 - The nonstandard TI-RPC library used internally by Ganesha

 - The RPC librar(ies) buried in Kerberos implementations

So there's more to do than simply removing the one in glibc,
unfortunately.


--
Chuck Lever



