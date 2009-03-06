From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] NFSD: fix handling of unsupported nfsv4 ops
Date: Fri, 6 Mar 2009 15:36:27 -0500
Message-ID: <20090306203627.GA1779@fieldses.org>
References: <49A6FD82.6080808@panasas.com> <20090304210200.GG28951@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs mailing list <pnfs@linux-nfs.org>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:56914 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754144AbZCFUge (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Mar 2009 15:36:34 -0500
In-Reply-To: <20090304210200.GG28951@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 04, 2009 at 04:02:00PM -0500, bfields wrote:
> On Thu, Feb 26, 2009 at 12:37:22PM -0800, Benny Halevy wrote:
> > Both patches fix issues I introduced in 2.6.27.
> > The first one is more crucial to get to the 2.6.2{7,8} stable streams
> > but while at it, I'd pull both.
> > This was triggered in connectathon with the Sun OpenSolaris
> > client trying to read extended attrs (when copying a file).
> > This translates to a NFS4 OP_OPENATTR which caused our server to barf.
> 
> Thanks!  But, sorry, somehow I didn't get both of these (probably a
> screwup on my end); would you mind resending?

Both applied now, thanks.--b.
