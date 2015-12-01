Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:52432 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989AbbLAHhV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Dec 2015 02:37:21 -0500
Date: Tue, 1 Dec 2015 08:37:18 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, viro@zeniv.linux.org.uk,
        tao.peng@primarydata.com, jeff.layton@primarydata.com,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 2/5] locks: new locks_mandatory_area calling convention
Message-ID: <20151201073718.GA29495@lst.de>
References: <1448563859-21922-1-git-send-email-hch@lst.de> <1448563859-21922-3-git-send-email-hch@lst.de> <20151130223830.GB31564@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151130223830.GB31564@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 30, 2015 at 05:38:30PM -0500, J. Bruce Fields wrote:
> > +	if (size < inode->i_size) {
> > +		return locks_mandatory_area(filp, size, inode->i_size - 1,
> > +				true);
> > +	} else {
> > +		return locks_mandatory_area(filp, inode->i_size, size - 1,
> > +				true);
> 
> I feel like these callers would be just slightly more self-documenting
> if that last parameter was F_WRLCK instead of true.

Sure, I can change that forthe next version.

