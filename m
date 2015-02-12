Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46346 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbbBLMcg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2015 07:32:36 -0500
Date: Thu, 12 Feb 2015 04:32:35 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas D Haynes <thomas.haynes@primarydata.com>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
Message-ID: <20150212123235.GB30583@infradead.org>
References: <20150205141325.GC4522@infradead.org>
 <54D394EC.9030902@Netapp.com>
 <20150205162326.GA18977@infradead.org>
 <54D39DC2.9060808@Netapp.com>
 <20150205164832.GB4289@fieldses.org>
 <54DB7D72.5020001@Netapp.com>
 <CAHQdGtTujOS5QZSaTbEy2sK0aZpoWmo-qmjgxb_iuue_5b=46A@mail.gmail.com>
 <20150211162244.GH25696@fieldses.org>
 <CAHQdGtTOdGh8pzseGdE6J8onoid-4ee4O=ra9sSS5aD_nWov+w@mail.gmail.com>
 <20150211164219.GI25696@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150211164219.GI25696@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 11:42:19AM -0500, J. Bruce Fields wrote:
> I guess.  Presumably the filesystem already does something like that on
> read, so I find it hard to imagine that extra check is expensive,
> especially if it's amortized over large-ish reads.  Seems worth checking
> at least.

The filesystem zero-fills blocks when reading them from disk, which is
serveral layers away from where it interacts with nfsd.  We've been
looking at an extension to read to return AGAIN when data can't be read
at the momemnt, it would be logical to base on that and just return a
hole size if there isn't any data, but implementing that would be a fair
amount of work.
