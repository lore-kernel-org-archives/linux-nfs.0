Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51526 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbaDSOiG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Apr 2014 10:38:06 -0400
Date: Sat, 19 Apr 2014 07:38:04 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 21/70] NFSd: Get rid of the lockowner_ino_hashtbl
Message-ID: <20140419143804.GB25682@infradead.org>
References: <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2014 at 02:44:15PM -0400, Trond Myklebust wrote:
> It is no longer used.

I think this should be folded into the previous patch, which is the
reason why it is unused now.

