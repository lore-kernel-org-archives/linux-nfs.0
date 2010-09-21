From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [bfields-btOuF8jVhiP3NsPE3w5/ayCwEArCW2h5@public.gmane.org: all f08d6374 Merge branch
 'nfs-for-next' into linux-next results]
Date: Tue, 21 Sep 2010 15:42:02 -0400
Message-ID: <20100921194202.GD4385@fieldses.org>
References: <20100918171546.GA9859@fieldses.org>
 <1284831680.2787.1.camel@heimdal.trondhjem.org>
 <20100919184549.GD32071@fieldses.org>
 <20100920130106.GB4580@fieldses.org>
 <20100920131025.GC4580@fieldses.org>
 <1285091815.30222.19.camel@heimdal.trondhjem.org>
 <20100921111657.330e7838@corrin.poochiereds.net>
 <20100921192005.GC4385@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44599 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444Ab0IUTna (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 15:43:30 -0400
In-Reply-To: <20100921192005.GC4385@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 21, 2010 at 03:20:05PM -0400, J. Bruce Fields wrote:
> All I need to do is mount nfs4.1 and run cthon -s.  The last output I
> see from the test is:
> 
> check for proper open/unlink operation
> nfsjunk files before unlink:
>   
> 
> That's on a kernel without Trond's fix above.

But, as expected, that fix makes no difference.

--b.
