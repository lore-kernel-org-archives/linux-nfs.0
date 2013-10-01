Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38975 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924Ab3JANeO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Oct 2013 09:34:14 -0400
Date: Tue, 1 Oct 2013 06:34:12 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Benny Halevy <bhalevy@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 20/49] pnfsd: filelayout: layout encoding
Message-ID: <20131001133412.GC32431@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220872-13597-1-git-send-email-bhalevy@primarydata.com>
 <20130929121639.GD21083@infradead.org>
 <524A2225.8020000@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <524A2225.8020000@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 30, 2013 at 06:15:17PM -0700, Boaz Harrosh wrote:
> Though I would like to keep it here, because I have a patchset
> which implements pNFS without NFSD at all. It enables a set
> of IOCTLs or syscalls and uses the same exact FS interface
> introduced here but sends the info to a user mode server.

If you want your userlevel fs use ganesha.  The kernel is a
self-contained project and not a random library. 

