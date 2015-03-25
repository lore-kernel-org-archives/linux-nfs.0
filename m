Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:50017 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932262AbbCYRqe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2015 13:46:34 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 4BEC92804A7
	for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2015 18:36:50 +0100 (CET)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 3FA2213E96
	for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2015 18:36:50 +0100 (MET)
Date: Wed, 25 Mar 2015 18:36:49 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <690536960.86520.1427305009735.JavaMail.zimbra@desy.de>
In-Reply-To: <CAABAsM5qmPK0WgED0FkfHCt0E_r9BYq1VftC8Kxhfw77X52+9g@mail.gmail.com>
References: <CAABAsM5qmPK0WgED0FkfHCt0E_r9BYq1VftC8Kxhfw77X52+9g@mail.gmail.com>
Subject: Re: [PATCH 4/4] NFSv4.1: Don't cache deviceids that have no
 notifications
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> To: "Christoph Hellwig" <hch@infradead.org>
> Cc: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>, "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
> Sent: Wednesday, March 25, 2015 1:49:19 PM
> Subject: Re: [PATCH 4/4] NFSv4.1: Don't cache deviceids that have no notifications

> On Wed, Mar 25, 2015 at 4:55 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> On Sun, Mar 22, 2015 at 03:27:32PM -0400, Trond Myklebust wrote:
>>> No. The right fix is to make the server support device notifications.
>>
>> And you instantly thrash performane on any server that doesn't, which
>> is why I sent out the errata that no one objected out.  I'm happy to
>> open this again on the WG list, but the notification scheme is such a
>> big hammer that it absolutely isn't worth implementing.  Given how
>> GETDEVICELIST is specified in 4.1 the original RFC language also is
>> inconsistent with itself, so that's not an argument for the old
>> behavior.
> 
> The reason for the GETDEVICEINFO description in RFC5661 is that you
> need some mechanism to allow clients to know when a deviceid is
> retired. There is no reasonable alternative to notification that
> doesn't cause problems on either the client or the server.
> 
> That said, do note that one valid solution here is to have deviceids
> that never expire (i.e. if you need to retire them, then you allocate
> a new one). Given that the deviceid is a 128-bit field, such a
> solution is 100% practical. That would allow you to say you support
> notification, but not have to implement it.


I wasn't happy with that change either. But it was easy to add
a simple (single bit) hack and lie to client, that server supports
notifications. Eventually, if one-time device IDs will be required,
client already will do the right thing, which is good.

Tigran.

> 
> Trond
