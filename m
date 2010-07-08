From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFSD: Fill in WCC data for REMOVE, RMDIR, MKNOD, and
 MKDIR
Date: Thu, 8 Jul 2010 15:50:48 -0400
Message-ID: <20100708195047.GA31173@fieldses.org>
References: <20100706204750.2918.92546.stgit@ellison.1015granger.net>
 <20100707211037.GF2957@fieldses.org>
 <4C35E874.3050809@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42516 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755918Ab0GHTuz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jul 2010 15:50:55 -0400
In-Reply-To: <4C35E874.3050809@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 08, 2010 at 11:02:12AM -0400, Chuck Lever wrote:
> On 07/ 7/10 05:10 PM, J. Bruce Fields wrote:
> >On Tue, Jul 06, 2010 at 04:53:34PM -0400, Chuck Lever wrote:
> >>Some well-known NFSv3 clients drop their directory entry caches when
> >>they receive replies with no WCC data.
> >
> >Can we include any more details?  (And/or a simple test case that
> >demonstrates the difference?)
> 
> I have a version of this patch with a much more comprehensive
> description which I can post later today.
> 
> As for a test case... among other things, I untarred a large tarball
> on a Mac OS 10.6 NFS client, and, once the server was fixed, it went
> as quickly as you would expect.  Before, it took much longer.

By the way, why isn't this reproduceable on the Linux client?

If it's ignoring whether updates are atomic--is that really OK?

--b.
