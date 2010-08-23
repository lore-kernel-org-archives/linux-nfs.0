Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35618 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752718Ab0HWWcp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Aug 2010 18:32:45 -0400
Date: Mon, 23 Aug 2010 18:32:38 -0400
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>,
        "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH version2] nfsd41: Fix a crash when a callback is retried
Message-ID: <20100823223238.GB25890@fieldses.org>
References: <4C28DCE0.7050201@panasas.com>
 <4C29DA23.90200@panasas.com>
 <20100805142226.GA27141@fieldses.org>
 <4C724914.2050206@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C724914.2050206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 23, 2010 at 01:10:28PM +0300, Boaz Harrosh wrote:
> On 08/05/2010 05:22 PM, J. Bruce Fields wrote:
> > Thanks, applied.  There may be a delay before it shows up in my
> > for-2.6.36 queue, while I sort out a few other bugs.
> > 
> > (We still have problems here: getting a new slot isn't always the
> > correct thing to do, depending on the error.  But this seems an
> > improvement....).
> > 
> 
> We do free the slot unconditionally, (hence the crash) so we better
> grab a new one.
> 
> Please store in the corner of your mind those cases you think should
> not free the slot, I promise to put it on my todo, and come back to it.

OK, thanks.

Might be worth starting by looking at the client code, as we probably
have to handle all the same errors in cb_sequence replies as are handled
in sequence replies.

--b.
