Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57082 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089AbcAHTgd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jan 2016 14:36:33 -0500
Date: Fri, 8 Jan 2016 14:36:31 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [RFC PATCH 2/2] nfsd: give up on CB_LAYOUTRECALLs after two
 lease periods
Message-ID: <20160108193631.GD5031@fieldses.org>
References: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com>
 <1449577428-13181-3-git-send-email-jeff.layton@primarydata.com>
 <20151222132538.GA25509@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151222132538.GA25509@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 22, 2015 at 02:25:38PM +0100, Christoph Hellwig wrote:
> Ok, this tests fine for me:
> 
> Tested-by: Christoph Hellwig <hch@lst.de>

Thanks, applying for 4.5.

(Missed your reviewed-by on the other patch when I submitted that for
stable, apologies.)

I did a little work on some pynfs tests to exercise some of the failure
cases here, but didn't get very far; I'll post something if I get a
chance to test them.  I think those tests are what we'd need before
doing something more sophisticated.

--b.
