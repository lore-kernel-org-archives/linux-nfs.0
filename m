Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41488 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854AbbBLM35 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2015 07:29:57 -0500
Date: Thu, 12 Feb 2015 04:29:50 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas D Haynes <thomas.haynes@primarydata.com>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
Message-ID: <20150212122950.GA30583@infradead.org>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20150205141325.GC4522@infradead.org>
 <54D394EC.9030902@Netapp.com>
 <20150205162326.GA18977@infradead.org>
 <54D39DC2.9060808@Netapp.com>
 <20150205164832.GB4289@fieldses.org>
 <54DB7D72.5020001@Netapp.com>
 <CAHQdGtTujOS5QZSaTbEy2sK0aZpoWmo-qmjgxb_iuue_5b=46A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTujOS5QZSaTbEy2sK0aZpoWmo-qmjgxb_iuue_5b=46A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 11:13:38AM -0500, Trond Myklebust wrote:
> I'm wondering if the right way to do READ_PLUS would have been to
> instead have a separate function READ_SPARSE, that will return a list
> of all sparse areas in the supplied range. We could even make that a
> READ_SAME, that can do the same for patterned data.

That soudns like the protocol level equivalent of the fiemap ioctl.

While fiemap is useful for filesystem debugging, using it for detection
of sparse ranges in oreutils turned out to be a desaster, and we instead
oved to support lseek SEEK_DATA/SEEK_HOLE, which would map to SEEK in
NFSv4.2.

The userspace tools use the different in file size vs allocate blocks
in the stat data to decide if they use SEEK_DATA/SEEK_HOLE, which should
work just fine over NFSv4.2 as well.
