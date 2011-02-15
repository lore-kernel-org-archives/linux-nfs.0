Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53123 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755083Ab1BOPGa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 10:06:30 -0500
Date: Tue, 15 Feb 2011 10:06:28 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Christoph Hellwig <hch@infradead.org>, Fred Isaman <iisaman@netapp.com>,
        andros@netapp.com, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/16] pnfs: wave 3: lseg refcounting
Message-ID: <20110215150628.GA24358@infradead.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
 <1297711116-3139-9-git-send-email-andros@netapp.com>
 <20110215092531.GB29871@infradead.org>
 <AANLkTik+dVSmWgO6LRANo2xTt6iMqQ7ehvgqk-igQFhM@mail.gmail.com>
 <20110215145828.GA18038@infradead.org>
 <4D5A94CD.4030508@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D5A94CD.4030508@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Btw, what's the point for deferring the free_lseg calls?  It looks like it's
to avoid calling something that might block under i_lock, but looking around
the pnfs-submit branch it seems that root cause could be fixed trivially.

In common code *free_lseg* and *put_layout_hdr* do nothing but list
manipulations and kfrees.  And in filelayout_free_lseg we have just kfrees
and a call to pnfs_put_deviceid which may sleep due to calling
synchronize_rcu.  But synchronize_rcu is horribly inefficient to start with,
and you'd better be off using call_rcu to free the device id, which will
lead to much saner code and better performance.

