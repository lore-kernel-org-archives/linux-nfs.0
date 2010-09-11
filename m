From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] mount.nfs: Refactor mount version and protocol
 autonegotiation
Date: Sat, 11 Sep 2010 00:06:19 -0400
Message-ID: <20100911040619.GA24749@fieldses.org>
References: <20100831212006.21061.17002.stgit@matisse.1015granger.net>
 <20100831212130.21061.10519.stgit@matisse.1015granger.net>
 <20100907111246.7de7d757@notabene>
 <D0DBF3C1-0C80-4C30-8344-39974AD7CBD6@oracle.com>
 <20100910072337.1c66dde3@notabene>
 <1284068734.14656.39.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35268 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981Ab0IKEHV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 11 Sep 2010 00:07:21 -0400
In-Reply-To: <1284068734.14656.39.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 09, 2010 at 05:45:34PM -0400, Trond Myklebust wrote:
> On Fri, 2010-09-10 at 07:23 +1000, Neil Brown wrote:
> > On Thu, 9 Sep 2010 13:27:38 -0400
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > > 
> > > Perhaps that violates Bruce's "too subtle" rule and I should replace it with your suggested post-call check?
> > 
> > He's like a guardian angel sitting on you shoulder whispering "too subtle"
> > all the time :-)  Definitely true this time.
> 
> The mind boggles at the thought of Bruce perching on anyone's
> shoulder...

Would somebody please just offer me a chair?

--b.
