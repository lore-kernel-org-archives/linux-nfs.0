Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:35930 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755759AbbAIKFy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2015 05:05:54 -0500
Date: Fri, 9 Jan 2015 11:05:51 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: [PATCH 09/18] nfsd: implement pNFS operations
Message-ID: <20150109100551.GA23173@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-10-git-send-email-hch@lst.de> <20150108164851.03b64e16@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150108164851.03b64e16@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2015 at 04:48:51PM -0800, Jeff Layton wrote:
> > +	nfsd4_return_all_file_layouts(stp->st_stateowner->so_client,
> > +				      stp->st_stid.sc_file);
> > +
> 
> Shouldn't the above be conditional on whether the lg_roc was true?

There is no support for non-lg_roc layouts at the moment.

In general I've avoided adding code that isn't used, as they can't
be tested and thus most likely won't work.
