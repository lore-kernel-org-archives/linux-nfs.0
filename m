Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:37446 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625Ab3JABV3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 21:21:29 -0400
Message-ID: <524A237F.2060100@panasas.com>
Date: Mon, 30 Sep 2013 18:21:03 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Benny Halevy <bhalevy@primarydata.com>
CC: "J. Bruce Fields" <bfields@redhat.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC v0 29/49] pnfsd: support layout_type attribute
References: <52447EA0.7070004@primarydata.com> <1380220908-14009-1-git-send-email-bhalevy@primarydata.com> <20130929121723.GE21083@infradead.org>
In-Reply-To: <20130929121723.GE21083@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/29/2013 05:17 AM, Christoph Hellwig wrote:
> Seems like layout_type should just be a field in the export ops instead
> of a method.

No! this field does not make any sense at all it should just be
removed.

There is a pNFS inquiry a client sends that asks for an array
of all the types supported by this mount point. So these method
should be returning an array. If at all.

The layout_type is just an input to some operations and are
no concern of NFSD. This is not a yes/no flag for pNFS the
opts vector should be the flag.

Cheers
Boaz

