From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFSD: Fix a bug in the NFSv4 'supported attrs' mandatory
 attribute
Date: Mon, 31 Aug 2009 18:29:50 -0400
Message-ID: <1251757790.25048.16.camel@heimdal.trondhjem.org>
References: <1251746171.25048.1.camel@heimdal.trondhjem.org>
	 <20090831220324.GC5718@fieldses.org>
	 <1251757313.25048.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47384 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929AbZHaWaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2009 18:30:19 -0400
In-Reply-To: <1251757313.25048.12.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-31 at 18:21 -0400, Trond Myklebust wrote:
> On Mon, 2009-08-31 at 18:03 -0400, J. Bruce Fields wrote:
> > If you want to do this, you probably also want to turn off the previous
> > exfslocs.locations check in the same function.  Otherwise we claim
> > support for the attribute but then never actually return it.
> 
> ...why is that a problem? Clients that conform to RFC3530 are perfectly
> capable of dealing with that case. The point is that if you say "I don't
> support this attribute", then the client will _never_ be allowed to
> check it.

Put differently: not setting the fs_locations bit in the supp_attr
information is equivalent to telling the client that it shouldn't ask
for it, and there is no time limit on that prohibition...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
