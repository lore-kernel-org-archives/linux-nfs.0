Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:58535 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756671Ab0BXLS2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Feb 2010 06:18:28 -0500
In-Reply-To: <20100224052215.GH16175@discord.disaster>
References: <20100224024100.GA17048@localhost>
	 <20100224032934.GF16175@discord.disaster>
	 <20100224041822.GB27459@localhost>
	 <20100224052215.GH16175@discord.disaster>
Date: Wed, 24 Feb 2010 06:18:26 -0500
Message-ID: <e48344781002240318u6e6545bdt97712dca4efceb9f@mail.gmail.com>
Subject: Re: [RFC] nfs: use 2*rsize readahead size
From: Akshat Aranya <aaranya+fsdevel@gmail.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Linux Memory Management List <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 24, 2010 at 12:22 AM, Dave Chinner <david@fromorbit.com> wrote:

>
>> It sounds silly to have
>>
>>         client_readahead_size > server_readahead_size
>
> I don't think it is  - the client readahead has to take into account
> the network latency as well as the server latency. e.g. a network
> with a high bandwidth but high latency is going to need much more
> client side readahead than a high bandwidth, low latency network to
> get the same throughput. Hence it is not uncommon to see larger
> readahead windows on network clients than for local disk access.
>
> Also, the NFS server may not even be able to detect sequential IO
> patterns because of the combined access patterns from the clients,
> and so the only effective readahead might be what the clients
> issue....
>

In my experiments, I have observed that the server-side readahead
shuts off rather quickly even with a single client because the client
readahead causes multiple pending read RPCs on the server which are
then serviced in random order and the pattern observed by the
underlying file system is non-sequential.  In our file system, we had
to override what the VFS thought was a random workload and continue to
do readahead anyway.

Cheers,
Akshat
