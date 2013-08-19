Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:45645 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820Ab3HSPz7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Aug 2013 11:55:59 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so4779431pad.0
        for <linux-nfs@vger.kernel.org>; Mon, 19 Aug 2013 08:55:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130816211217.GB21539@fieldses.org>
References: <CAJUS3XmebzQHnQNwEYECUjYyK+nj2cVpKz_-4gmPacEWzmxEZQ@mail.gmail.com>
	<20130816211217.GB21539@fieldses.org>
Date: Mon, 19 Aug 2013 11:55:58 -0400
Message-ID: <CAJUS3Xk=vqunKx8bKGV2iWTV=o9N_TX3h+2PL0iMm3m7FKjuig@mail.gmail.com>
Subject: Re: server mountpoint busy after unexporting nfs4 share
From: Martin Hicks <mort@bork.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

On Fri, Aug 16, 2013 at 5:12 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Aug 15, 2013 at 12:04:33PM -0400, Martin Hicks wrote:
>> I'm wondering if I'm missing something or if this is a bug.
>>
>> A NFS4 export has active clients.  The mount is removed from
>> /etc/exports and 'exportfs -r' is run.  Clients immediately start
>> getting 'Stale file handle' errors, but the mountpoint is still busy
>> and cannot be unmounted.  Killing off nfsd solves the problem, but is
>> undesirable for obvious reasons.
>>
>> On debian linux, kernel version 3.10-2-amd64,  with nfs-utils 1.2.8.
>
> Yeah, the clients may hold opens or locks on the filesystem and those
> don't get removed on exports -r.
>
> For now shutting down the server is the only solution.
>
> We could possibly fix that, or provide some other way to do whatever it
> is you're trying to do, but it's likely not a small change.

Essentially I've got a NAS with two doors that have removable disks
behind them.  I get a signal from hardware when one of the doors is
opened, and I need to kill services, unmount and remove the block
device very quickly so the user can remove or swap disks.  I was
trying to avoid killing nfsd so that any clients connected to the
block device behind the other door could continue uninterrupted.

If this isn't possible then I need to minimize the downtime to the
other disk.  With quick experiements this morning if I simply restart
nfs it seems to take between 60 and 90 seconds for the client to start
doing IO again.  I haven't tracked down the reason yet, but it seems
like the server is preventing the client from doing IO for some
time...

Thanks,
mh

-- 
Martin Hicks P.Eng.      |         mort@bork.org
Bork Consulting Inc.     |   +1 (613) 266-2296
