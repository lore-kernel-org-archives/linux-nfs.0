Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34738 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965172AbeALWIz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Jan 2018 17:08:55 -0500
Subject: Re: [Libtirpc-devel] [PATCH] Do not bind to reserved ports registered
 in /etc/services
To: Thorsten Kukuk <kukuk@suse.de>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Guillem Jover <gjover@sipwise.com>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <49E44F63-42CF-4BF8-91E0-F89945D7CFE6@oracle.com>
 <20180112180528.GA9479@thunder.hadrons.org>
 <BB34439C-4BC6-46AE-B2E8-45E5F7396F21@oracle.com>
 <20180112211219.GA17573@suse.de>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <3c3e0578-12e9-cfde-7abc-8a27621319a4@RedHat.com>
Date: Fri, 12 Jan 2018 17:08:53 -0500
MIME-Version: 1.0
In-Reply-To: <20180112211219.GA17573@suse.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/12/2018 04:12 PM, Thorsten Kukuk wrote:
> On Fri, Jan 12, Chuck Lever wrote:
> 
>>> On Jan 12, 2018, at 1:05 PM, Guillem Jover <gjover@sipwise.com> wrote:
> 
>>> [F] <https://sources.debian.org/src/glibc/2.26-3/debian/patches/any/local-bindresvport_blacklist.diff/>
>>>
>>> On the above Debian bug report, it was proposed to make libtirpc switch
>>> to use the libc bindresvport() implementation so that at least on those
>>> distributions where it is locally patched it would honor the
>>> /etc/bindresvport.blacklist file. The problem with this, is of course
>>> that it does not help any upstream code on any other non-patched system.
>>
>> The community issue here is that there have evolved, over time,
>> multiple RPC libraries with divergent capabilities. The only way
>> to truly address this confusion is to eliminate all but one of
>> them, which is far outside the scope of your bug fix. For now we
>> have to live with it.
> 
> openSUSE is removing sunrpc from glibc, Fedora seems to be removing
> sunrpc from glibc, so it's only a matter of time when libtirpc is the
> only RPC implementation used on Linux.
We are... 
   https://bugzilla.redhat.com/show_bug.cgi?id=1531540

We also adding a new package that will contain rpcgen
    https://bugzilla.redhat.com/show_bug.cgi?id=1532364

based off Thorsten's git tree
    https://github.com/thkukuk/rpcsvc-proto

steved.
