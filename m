Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:35883 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993178Ab2KOKXY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Nov 2012 05:23:24 -0500
Message-ID: <50A4C28B.8020307@parallels.com>
Date: Thu, 15 Nov 2012 14:23:07 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: [RFC PATCH v2 00/15] NFSd state containerization
References: <20121114152018.4708.63125.stgit@localhost.localdomain> <20121114220036.GD539@fieldses.org>
In-Reply-To: <20121114220036.GD539@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

15.11.2012 02:00, J. Bruce Fields пишет:
> On Wed, Nov 14, 2012 at 06:20:59PM +0300, Stanislav Kinsbursky wrote:
>> This patch set is my first attempt to containerize NFSv4 state - i.e. make it
>> works in networks namespace context.
>> I admit, that some of this new code could be partially rewritten during future
>> NFSd containerization.
>> But the overall idea look more or less correct to me.
>> So, the main things here are:
>> 1) making nfs4_client network namespace aware.
>> 2) Allocating all hashes (except file_hashtbl and reclaim_str_hashtbl) per
>> network namespace context on NFSd start (not init) and destroying on NFSd
>> state shutdown.
>> 3) Allocating of reclaim_str_hashtbl on legacy tracker start and destroying on
>> legacy tracker stop.
>> 4) Moving of client_lru and close_lru lists to per-net data.
>> 5) Making lundromat network namespace aware.
>
> These look OK and pass my tests.  Jeff, do the revised recovery bits
> look OK?
>
> Have you done any testing?

I've done basic testing. I.e. NFS server start/stop in loop, export, share mount 
on another node and some activity, etc.
NFS server is not ready yet to work on container, so no such testing has been done.

>
> It'd be interesting, for example, to know if there are any pynfs that
> fail against the server in a non-init network namespace, but pass
> normally.
>
> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
