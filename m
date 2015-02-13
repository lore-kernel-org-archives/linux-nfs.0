Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41442 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbbBMNYL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Feb 2015 08:24:11 -0500
Date: Fri, 13 Feb 2015 05:24:04 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas D Haynes <thomas.haynes@primarydata.com>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
Message-ID: <20150213132404.GA18920@infradead.org>
References: <20150205141325.GC4522@infradead.org>
 <54D394EC.9030902@Netapp.com>
 <20150205162326.GA18977@infradead.org>
 <54D39DC2.9060808@Netapp.com>
 <20150205164832.GB4289@fieldses.org>
 <54DB7D72.5020001@Netapp.com>
 <CAHQdGtTujOS5QZSaTbEy2sK0aZpoWmo-qmjgxb_iuue_5b=46A@mail.gmail.com>
 <20150211162244.GH25696@fieldses.org>
 <54DBABE7.9050403@Netapp.com>
 <54DD0631.8040802@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54DD0631.8040802@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 12, 2015 at 02:59:45PM -0500, Anna Schumaker wrote:
> Today I learned all about how to use operf to identify where the bottleneck is :).  It looks like the problem is in the hole zeroing code on the client side.  Is there a better way than memset() to mark a page as all zeros?

clear_highpage(), but I don't expect it to make a huge different.
