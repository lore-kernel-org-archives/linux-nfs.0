Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:44324 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751489AbbBBO4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Feb 2015 09:56:23 -0500
Date: Mon, 2 Feb 2015 15:56:19 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 10/20] nfsd: implement pNFS operations
Message-ID: <20150202145619.GA18387@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de> <1421925006-24231-11-git-send-email-hch@lst.de> <20150129203346.GA11064@fieldses.org> <20150202124349.GA15598@lst.de> <20150202142832.GC22301@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150202142832.GC22301@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 02, 2015 at 09:28:32AM -0500, J. Bruce Fields wrote:
> I didn't notice anything that looked like a big problem to me, so absent
> any objections I'll commit the revised versions for 3.20 once we figure
> out how to handle the xfs stuff.

Do you want the resend to be on top of Jeffs locks tree, or do you
want me to be based just on the nfsd changes, which would require
a fairly trivial merge once both of the trees hit mainline?
