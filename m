Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35702 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbbCYMtU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 08:49:20 -0400
Received: by obcjt1 with SMTP id jt1so18197716obc.2
        for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2015 05:49:19 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 25 Mar 2015 08:49:19 -0400
Message-ID: <CAABAsM5qmPK0WgED0FkfHCt0E_r9BYq1VftC8Kxhfw77X52+9g@mail.gmail.com>
Subject: Re: [PATCH 4/4] NFSv4.1: Don't cache deviceids that have no notifications
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2015 at 4:55 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Sun, Mar 22, 2015 at 03:27:32PM -0400, Trond Myklebust wrote:
>> No. The right fix is to make the server support device notifications.
>
> And you instantly thrash performane on any server that doesn't, which
> is why I sent out the errata that no one objected out.  I'm happy to
> open this again on the WG list, but the notification scheme is such a
> big hammer that it absolutely isn't worth implementing.  Given how
> GETDEVICELIST is specified in 4.1 the original RFC language also is
> inconsistent with itself, so that's not an argument for the old
> behavior.

The reason for the GETDEVICEINFO description in RFC5661 is that you
need some mechanism to allow clients to know when a deviceid is
retired. There is no reasonable alternative to notification that
doesn't cause problems on either the client or the server.

That said, do note that one valid solution here is to have deviceids
that never expire (i.e. if you need to retire them, then you allocate
a new one). Given that the deviceid is a 128-bit field, such a
solution is 100% practical. That would allow you to say you support
notification, but not have to implement it.

Trond
