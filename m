Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:33264 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439AbaLJLwm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 06:52:42 -0500
Received: by mail-qg0-f50.google.com with SMTP id i50so1904194qgf.23
        for <linux-nfs@vger.kernel.org>; Wed, 10 Dec 2014 03:52:42 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 10 Dec 2014 06:52:40 -0500
To: David =?UTF-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        SteveD@redhat.com, dhowells@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141210065240.77a23160@tlielax.poochiereds.net>
In-Reply-To: <20141209195530.GA27798@hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
	<20141209080923.2708eb4f@tlielax.poochiereds.net>
	<4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu>
	<20141209095813.163ac2bb@tlielax.poochiereds.net>
	<20141209195530.GA27798@hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Dec 2014 20:55:30 +0100
David Härdeman <david@hardeman.nu> wrote:

> On Tue, Dec 09, 2014 at 09:58:13AM -0500, Jeff Layton wrote:
> >> On 2014-12-09 14:09, Jeff Layton wrote:
> >>> One thing that _would_ be nice while you're in here though would be to
> >>> help parallelize more of process_krb5_upcall. Currently it forks before
> >>> changing its identity and then the parent waits on that to exit which
> >>> keeps everything serialized.
> >
> >Ahh, now I remember. It's not the closing of the fds that's the
> >problem, but you do need to have some way to reap the exit status from
> >the processes that are being forked off (so you don't end up with
> >zombies).
> 
> That's probably something that's been looked into before with libevent
> (says he, without doing any research).
> 

I imagine so.

> Another question that comes to mind...if we're anyway forking a child
> per gssd request...how far has the idea of changing rpc.gssd over to a
> /sbin/request-key helper been considered? I've seen some traces of
> historical discussions via google but nothing concrete so far...
> 

(cc'ing David in case I'm wrong on this point)

Yes. The problem with keyrings is that while the in-kernel parts are
namespace-aware, the upcalls are not. /sbin/request-key is spawned by a
kernel thread that lives in the init namespaces. Any solution that
involves a usermodehelper upcall will need to figure out how to handle
containerized clients.

Another idea might be to scrap rpc.gssd altogether and communicate with
gssproxy directly (but that too involves running a daemon, of course).

-- 
Jeff Layton <jlayton@primarydata.com>
