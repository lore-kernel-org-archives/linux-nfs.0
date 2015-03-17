Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38489 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753836AbbCQUHj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 16:07:39 -0400
Date: Tue, 17 Mar 2015 16:07:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 3/3] NFSD: Add support for encoding multiple segments
Message-ID: <20150317200738.GD29843@fieldses.org>
References: <1426540688-32095-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1426540688-32095-4-git-send-email-Anna.Schumaker@Netapp.com>
 <20150317195633.GC29843@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150317195633.GC29843@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 17, 2015 at 03:56:33PM -0400, J. Bruce Fields wrote:
> On Mon, Mar 16, 2015 at 05:18:08PM -0400, Anna Schumaker wrote:
> > This patch implements sending an array of segments back to the client.
> > Clients should be prepared to handle multiple segment reads to make this
> > useful.  We try to splice the first data segment into the XDR result,
> > and remaining segments are encoded directly.
> 
> I'm still interested in what would happen if we started with an
> implementation like:
> 
> 	- if the entire requested range falls within a hole, return that
> 	  single hole.
> 	- otherwise, just treat the thing as one big data segment.
> 
> That would provide a benefit in the case there are large-ish holes
> with minimal impact otherwise.
> 
> (Though patches for full support are still useful even if only for
> client-testing purposes.)

Also, looks like

	xvs_io -c "fiemap -v" <file>

will give hole sizes for a given <file>.  (Thanks, esandeen.)  Running
that on a few of my test vm images shows a fair number of large
(hundreds of megs) files, which suggests identifying only >=rwsize holes
might still be useful.

--b.
