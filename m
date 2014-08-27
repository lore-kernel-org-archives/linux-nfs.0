Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:34469 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754678AbaH0Rme (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2014 13:42:34 -0400
Date: Wed, 27 Aug 2014 10:42:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: bjschuma@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NFSD: Create nfs v4.2 decode ops
Message-ID: <20140827174231.GA13128@infradead.org>
References: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
 <1409152678-7806-3-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409152678-7806-3-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 27, 2014 at 11:17:57AM -0400, bjschuma@netapp.com wrote:
> From: Anna Schumaker <Anna.Schumaker@netapp.com>
> 
> It's cleaner to introduce everything at once and have the server reply
> with "not supported" than it would be to introduce extra operations when
> implementing a specific one in the middle of the list.

What prevents a client from calling the new operations on a 4.1 session?

