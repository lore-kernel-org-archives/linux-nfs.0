Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51691 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbaLITzl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 14:55:41 -0500
Date: Tue, 9 Dec 2014 20:55:30 +0100
From: David =?iso-8859-1?Q?H=E4rdeman?= <david@hardeman.nu>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141209195530.GA27798@hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
 <20141209080923.2708eb4f@tlielax.poochiereds.net>
 <4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu>
 <20141209095813.163ac2bb@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20141209095813.163ac2bb@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 09, 2014 at 09:58:13AM -0500, Jeff Layton wrote:
>> On 2014-12-09 14:09, Jeff Layton wrote:
>>> One thing that _would_ be nice while you're in here though would be to
>>> help parallelize more of process_krb5_upcall. Currently it forks before
>>> changing its identity and then the parent waits on that to exit which
>>> keeps everything serialized.
>
>Ahh, now I remember. It's not the closing of the fds that's the
>problem, but you do need to have some way to reap the exit status from
>the processes that are being forked off (so you don't end up with
>zombies).

That's probably something that's been looked into before with libevent
(says he, without doing any research).

Another question that comes to mind...if we're anyway forking a child
per gssd request...how far has the idea of changing rpc.gssd over to a
/sbin/request-key helper been considered? I've seen some traces of
historical discussions via google but nothing concrete so far...

-- 
David Härdeman
