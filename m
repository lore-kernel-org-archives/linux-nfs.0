Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59556 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbaIDRrF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 13:47:05 -0400
Date: Thu, 4 Sep 2014 10:47:04 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 02/17] security: make security_file_set_fowner,
 f_setown and __f_setown void return
Message-ID: <20140904174704.GB16935@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-3-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409834323-7171-3-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2014 at 08:38:28AM -0400, Jeff Layton wrote:
> security_file_set_fowner always returns 0, so make it f_setown and
> __f_setown void return functions and fix up the error handling in the
> callers.

All the LSMs seems to use this purely for setting up pointers, and not
having to handle errors in the locking code for it will make life a lot
simpler.  I like this a lot.

Reviewed-by: Christoph Hellwig <hch@lst.de>
