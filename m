Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:36565 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbbCYNvc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 09:51:32 -0400
Received: by yhjf44 with SMTP id f44so11626385yhj.3
        for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2015 06:51:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150325134531.GA25051@infradead.org>
References: <CAABAsM5qmPK0WgED0FkfHCt0E_r9BYq1VftC8Kxhfw77X52+9g@mail.gmail.com>
	<20150325134531.GA25051@infradead.org>
Date: Wed, 25 Mar 2015 09:51:31 -0400
Message-ID: <CAHQdGtS2mL8vXswVVYdjxza0eOi05tdTBvaRhKM8P1AzL6hz6g@mail.gmail.com>
Subject: Re: [PATCH 4/4] NFSv4.1: Don't cache deviceids that have no notifications
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2015 at 9:45 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Mar 25, 2015 at 08:49:19AM -0400, Trond Myklebust wrote:
>> The reason for the GETDEVICEINFO description in RFC5661 is that you
>> need some mechanism to allow clients to know when a deviceid is
>> retired. There is no reasonable alternative to notification that
>> doesn't cause problems on either the client or the server.
>>
>> That said, do note that one valid solution here is to have deviceids
>> that never expire (i.e. if you need to retire them, then you allocate
>> a new one). Given that the deviceid is a 128-bit field, such a
>> solution is 100% practical. That would allow you to say you support
>> notification, but not have to implement it.
>
> Deviceid must never be retired and reused, to quote from 12.2.10.:
>
> Once a device ID is
> deleted by the server, the server MUST NOT reuse the device ID for
> the same layout type and client ID again.  This requirement is
> feasible because the device ID is 16 bytes long, leaving sufficient
> room to store a generation number if the server's implementation
> requires most of the rest of the device ID's content to be reused.
> This requirement is necessary because otherwise the race conditions
> between asynchronous notification of device ID addition and deletion
> would be too difficult to sort out.

That doesn't change what I said about the feasibility of working
around the notification requirement.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
