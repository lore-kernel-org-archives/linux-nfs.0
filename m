Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:35397 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbbCYNpd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 09:45:33 -0400
Date: Wed, 25 Mar 2015 06:45:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSv4.1: Don't cache deviceids that have no
 notifications
Message-ID: <20150325134531.GA25051@infradead.org>
References: <CAABAsM5qmPK0WgED0FkfHCt0E_r9BYq1VftC8Kxhfw77X52+9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAABAsM5qmPK0WgED0FkfHCt0E_r9BYq1VftC8Kxhfw77X52+9g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2015 at 08:49:19AM -0400, Trond Myklebust wrote:
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

Deviceid must never be retired and reused, to quote from 12.2.10.:

Once a device ID is
deleted by the server, the server MUST NOT reuse the device ID for
the same layout type and client ID again.  This requirement is
feasible because the device ID is 16 bytes long, leaving sufficient
room to store a generation number if the server's implementation
requires most of the rest of the device ID's content to	be reused.
This requirement is necessary because otherwise the race conditions
between asynchronous notification of device ID addition and deletion
would be too difficult to sort out.
