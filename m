Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:41051 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbbALMnF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2015 07:43:05 -0500
Date: Mon, 12 Jan 2015 13:43:02 +0100
From: Christoph Hellwig <hch@lst.de>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 14/18] nfsd: pNFS block layout driver
Message-ID: <20150112124302.GA29681@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-15-git-send-email-hch@lst.de> <20150112045606.GA107426@slacker.internal.excfb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150112045606.GA107426@slacker.internal.excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 11, 2015 at 11:56:06PM -0500, Tom Haynes wrote:
> Could you follow the client code convention by putting
> each layout type in a directory?

I have to say I hate that convention on the client side, so I'd
be happier to keep it as-is.
