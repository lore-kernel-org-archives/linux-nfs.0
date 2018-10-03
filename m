Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58112 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725799AbeJDGm2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 02:42:28 -0400
Date: Wed, 3 Oct 2018 19:51:53 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 13/15] knfsd: Simplify NFS duplicate replay cache
Message-ID: <20181003235153.GJ17517@fieldses.org>
References: <20181001144157.3515-8-trond.myklebust@hammerspace.com>
 <20181001144157.3515-9-trond.myklebust@hammerspace.com>
 <20181001144157.3515-10-trond.myklebust@hammerspace.com>
 <20181001144157.3515-11-trond.myklebust@hammerspace.com>
 <20181001144157.3515-12-trond.myklebust@hammerspace.com>
 <20181001144157.3515-13-trond.myklebust@hammerspace.com>
 <20181001144157.3515-14-trond.myklebust@hammerspace.com>
 <20181003171424.GG17517@fieldses.org>
 <15f0759d1fd9b6442d8634b1cb46fb59cbdf8c95.camel@hammerspace.com>
 <20181003181150.GH17517@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20181003181150.GH17517@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 03, 2018 at 02:11:50PM -0400, bfields@fieldses.org wrote:
> On Wed, Oct 03, 2018 at 06:01:36PM +0000, Trond Myklebust wrote:
> > On Wed, 2018-10-03 at 13:14 -0400, J . Bruce Fields wrote:
> > > On Mon, Oct 01, 2018 at 10:41:55AM -0400, Trond Myklebust wrote:
> > > > Simplify the duplicate replay cache by initialising the
> > > > preallocated
> > > > cache entry, so that we can use it as a key for the cache lookup.
> > > > 
> > > > Note that the 99.999% case we want to optimise for is still the one
> > > > where the lookup fails, and we have to add this entry to the cache,
> > > > so preinitialising should not cause a performance penalty.
> > > > 
> > > > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> > > > ---
> > > >  fs/nfsd/cache.h    |  6 +--
> > > >  fs/nfsd/nfscache.c | 94 ++++++++++++++++++++++------------------
> > > > ------
> > > >  2 files changed, 47 insertions(+), 53 deletions(-)
> > > > 
> > > > diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> > > > index b7559c6f2b97..bd77d5f6fe53 100644
> > > > --- a/fs/nfsd/cache.h
> > > > +++ b/fs/nfsd/cache.h
> > > > @@ -24,13 +24,13 @@ struct svc_cacherep {
> > > >  	unsigned char		c_state,	/* unused, inprog,
> > > > done */
> > > >  				c_type,		/* status, buffer
> > > > */
> > > >  				c_secure : 1;	/* req came from
> > > > port < 1024 */
> > > > -	struct sockaddr_in6	c_addr;
> > > >  	__be32			c_xid;
> > > > -	u32			c_prot;
> > > > +	__wsum			c_csum;
> > > >  	u32			c_proc;
> > > > +	u32			c_prot;
> > > >  	u32			c_vers;
> > > >  	unsigned int		c_len;
> > > > -	__wsum			c_csum;
> > > > +	struct sockaddr_in6	c_addr;
> > > >  	unsigned long		c_timestamp;
> > > >  	union {
> > > >  		struct kvec	u_vec;
> > > 
> > > Unless I've missed something subtle--I'll move this chunk into the
> > > next
> > > patch.--b.
> > 
> > Nothing too subtle. The only reason for keeping it in this patch is
> > because even with the current code, most of the comparisons hit the
> > c_xid and possibly sometimes the c_csum, so those are the main fields
> > that you want to try to keep in the same cache line.
> 
> That could use a comment.

I'm adding just

 struct svc_cacherep {
 	struct {
+		/* Keep often-read xid, csum in the same cache line: */
 		__be32			k_xid;
 		__wsum			k_csum;
 		u32			k_proc;

--b.
