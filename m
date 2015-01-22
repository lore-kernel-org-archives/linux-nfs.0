Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:49051 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752530AbbAVQVE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jan 2015 11:21:04 -0500
Date: Thu, 22 Jan 2015 17:21:00 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: a simple and scalable pNFS block layout server V2
Message-ID: <20150122162100.GA10801@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de> <0851E625-04F8-4DE0-971D-1EAB591B3F28@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <0851E625-04F8-4DE0-971D-1EAB591B3F28@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2015 at 11:04:15AM -0500, Chuck Lever wrote:
> I’m still not clear on what layout types are supported. Clearly
> the block layout type is supported. But you mention XFS here. Does
> that mean file layouts are also supported now? If so, can you
> briefly describe the architecture and any current limitations?
> 
> Did I miss documentation for how administrators construct layouts?

Only block layouts are supporte at the moment.  They are automatically
enabled when an XFS filesystem is exported.   There is no requirement
for the administrator to construct in layout, the only requirement
for working block layouts is shared storage that is accessible
to the NFS Server / MDS and the clients that wish to use pNFS‥

If you are interested in file layout support porting over the existing
file layout drivers from the old pNFS server tree should only be
a moderate effort, and at least the lexp code would be grately
simplified by the common recall infrastructure in this series.
