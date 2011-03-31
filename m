Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:60703 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757728Ab1CaNxj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Mar 2011 09:53:39 -0400
Date: Thu, 31 Mar 2011 15:53:38 +0200
From: Christoph Hellwig <hch@lst.de>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Rees <rees@citi.umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [RFC] spnfs-block: restore i_op->fallocate
Message-ID: <20110331135338.GA20235@lst.de>
References: <1301500460-16467-1-git-send-email-bhalevy@panasas.com> <20110330155811.GA21931@lst.de> <4D936453.2070501@panasas.com> <20110330173344.GA24631@lst.de> <4D942506.1020505@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D942506.1020505@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Btw, how is the spnfs-block support supposed to work at all?

fallocate creates unwritten extents, and I can't actually
spot a place that would later convert them to regular extents.
And how does it work for filesystems without ->fallocate like
ext3?

And how do we prevent clients from reading uninitialized
blocks in areas allocated on the server but not written
to yet.  Is there anything like unwritten extents in the
on the write protocol?

