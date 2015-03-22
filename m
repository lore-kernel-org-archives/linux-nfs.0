Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:35063 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbbCVT1d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Mar 2015 15:27:33 -0400
Received: by ykfs63 with SMTP id s63so63319569ykf.2
        for <linux-nfs@vger.kernel.org>; Sun, 22 Mar 2015 12:27:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150317103736.GA31940@infradead.org>
References: <1425931503-37261-1-git-send-email-trond.myklebust@primarydata.com>
	<1425931503-37261-2-git-send-email-trond.myklebust@primarydata.com>
	<1425931503-37261-3-git-send-email-trond.myklebust@primarydata.com>
	<1425931503-37261-4-git-send-email-trond.myklebust@primarydata.com>
	<1425931503-37261-5-git-send-email-trond.myklebust@primarydata.com>
	<20150317103736.GA31940@infradead.org>
Date: Sun, 22 Mar 2015 15:27:32 -0400
Message-ID: <CAHQdGtS4UU=ArTeLBWKaRzEj=j2dWmqhU+z61RLnzU1=Gp5aLw@mail.gmail.com>
Subject: Re: [PATCH 4/4] NFSv4.1: Don't cache deviceids that have no notifications
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 17, 2015 at 6:37 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Mar 09, 2015 at 04:05:03PM -0400, Trond Myklebust wrote:
>> The spec says that once all layouts that reference a given deviceid
>> have been returned, then we are only allowed to continue to cache
>> the deviceid if the metadata server supports notifications.
>
> This causes massive performance issues for object and block layout
> servers where a GETDEVICEINFO (or rather the client processing of it)
> is expensive.  Also it increases the deadlock potential as the
> GETDEVICEINFO generally isn't safe for writeback under memory pressure
> (and yes, we'll need more fixes in that area).
>
> I've also filed an errata a while ago to update the language in the spec
> in this area to be consistent and not enforce this behavior:
>
> http://www.rfc-editor.org/errata_search.php?rfc=5661&eid=4119
>
> I think the right fix is to have a shrinker that allows the nfs client
> to retire unused devices on a lru basis under memory pressure.

No. The right fix is to make the server support device notifications.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
