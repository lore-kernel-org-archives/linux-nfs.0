Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:35448 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755931Ab2KWRvG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Nov 2012 12:51:06 -0500
Message-ID: <50AFB749.8090507@oracle.com>
Date: Fri, 23 Nov 2012 11:50:01 -0600
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Zach Brown <zab@zabbo.net>,
        "Maxim V. Patlasov" <mpatlasov@parallels.com>,
        Mel Gorman <mgorman@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v4 23/31] nfs: simplify swap
References: <1353537671-26284-1-git-send-email-dave.kleikamp@oracle.com> <1353537671-26284-24-git-send-email-dave.kleikamp@oracle.com> <20121123082157.GC10731@infradead.org>
In-Reply-To: <20121123082157.GC10731@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/23/2012 02:21 AM, Christoph Hellwig wrote:
> On Wed, Nov 21, 2012 at 04:41:03PM -0600, Dave Kleikamp wrote:
>> swap_writepage can now call nfs's write_iter f_op, eliminating the need to
>> implement for the special-case direct_IO a_op. There is no longer a need to
>> pass the uio flag through the direct write path.
> 
> This should also kill off the nasty REQ_KERNEL flag.

Right. Missed that.

Shaggy
