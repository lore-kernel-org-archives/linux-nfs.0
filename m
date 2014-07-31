Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54831 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412AbaGaQxC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2014 12:53:02 -0400
Date: Thu, 31 Jul 2014 12:52:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v3 04/38] nfsd: Replace nfs4_ol_stateid->st_file with the
 st_stid.sc_file
Message-ID: <20140731165259.GB11218@fieldses.org>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
 <1406684083-19736-5-git-send-email-jlayton@primarydata.com>
 <20140730205902.GB25112@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140730205902.GB25112@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 30, 2014 at 01:59:02PM -0700, Christoph Hellwig wrote:
> FYI, I'd merge this into the previous patch.

OK, done.

--b.
