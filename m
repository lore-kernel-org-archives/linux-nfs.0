Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f50.google.com ([209.85.160.50]:60124 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab3HTRt7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Aug 2013 13:49:59 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so676557pbc.23
        for <linux-nfs@vger.kernel.org>; Tue, 20 Aug 2013 10:49:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130819184212.GA15945@fieldses.org>
References: <CAJUS3XmebzQHnQNwEYECUjYyK+nj2cVpKz_-4gmPacEWzmxEZQ@mail.gmail.com>
	<20130816211217.GB21539@fieldses.org>
	<CAJUS3Xk=vqunKx8bKGV2iWTV=o9N_TX3h+2PL0iMm3m7FKjuig@mail.gmail.com>
	<20130819184212.GA15945@fieldses.org>
Date: Tue, 20 Aug 2013 13:49:58 -0400
Message-ID: <CAJUS3XmYm390VtTzEyfqjVKdMxjd+QGbOnd7qTfwUTumZv8ewQ@mail.gmail.com>
Subject: Re: server mountpoint busy after unexporting nfs4 share
From: Martin Hicks <mort@bork.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 19, 2013 at 2:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Aug 19, 2013 at 11:55:58AM -0400, Martin Hicks wrote:
>> Hi Bruce,
>> >
>> > We could possibly fix that, or provide some other way to do whatever it
>> > is you're trying to do, but it's likely not a small change.
>>
>> Essentially I've got a NAS with two doors that have removable disks
>> behind them.  I get a signal from hardware when one of the doors is
>> opened, and I need to kill services, unmount and remove the block
>> device very quickly so the user can remove or swap disks.  I was
>> trying to avoid killing nfsd so that any clients connected to the
>> block device behind the other door could continue uninterrupted.
>
> OK, understood, so  you're mainly worried about access to the remaining
> data continuing uniterrrupted.
>
> That said--it's *really* not a problem that the other stuff starts
> erroring out immediately?  I imagine the typical application isn't
> going to handle the errors very gracefully.
>

This is a product where the client users of the system will be
designing us in from the beginning, so their applications have to
tolerate this type of disk swapping.

>> If this isn't possible then I need to minimize the downtime to the
>> other disk.  With quick experiements this morning if I simply restart
>> nfs it seems to take between 60 and 90 seconds for the client to start
>> doing IO again.  I haven't tracked down the reason yet, but it seems
>> like the server is preventing the client from doing IO for some
>> time...
>
> It's probably the grace period (which will block pretty much any IO for
> clients using NFSv4).

This is correct.  nfsv3 seems to recover quite quickly if I restart
the nfs services, in about 3 seconds.  I can see with wireshark that
the server is holding off the nfsv4 clients for quite a while with
NFS4ERR_GRACE.

Setting nfsv4gracetime (once I also found fs.nfs.nlm_grace_period) get
the drop-out time to just above 10 seconds, which is the minimum
nfsv4gracetime.  That'll have to do for now.

Thanks again,
mh

-- 
Martin Hicks P.Eng.      |         mort@bork.org
Bork Consulting Inc.     |   +1 (613) 266-2296
