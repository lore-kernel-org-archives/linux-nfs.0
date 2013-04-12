Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59408 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752409Ab3DLSdk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Apr 2013 14:33:40 -0400
Date: Fri, 12 Apr 2013 14:33:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "simo@redhat.com" <simo@redhat.com>
Subject: Re: [PATCH 5/6] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
Message-ID: <20130412183332.GN7081@fieldses.org>
References: <1361464705-12340-1-git-send-email-bfields@redhat.com>
 <1361464705-12340-6-git-send-email-bfields@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9235DA682@SACEXCMBX04-PRD.hq.netapp.com>
 <20130412181151.GM7081@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA928712C8D@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA928712C8D@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 12, 2013 at 06:21:11PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > Sent: Friday, April 12, 2013 2:12 PM
> > To: Myklebust, Trond
> > Cc: J. Bruce Fields; linux-nfs@vger.kernel.org; chuck.lever@oracle.com;
> > simo@redhat.com
> > Subject: Re: [PATCH 5/6] SUNRPC: Add RPC based upcall mechanism for
> > RPCGSS auth
> > 
> > Trond, apologies, I'm just getting back to this and had a couple
> > questions:
> > 
> > On Thu, Feb 21, 2013 at 06:35:46PM +0000, Myklebust, Trond wrote:
> > > On Thu, 2013-02-21 at 11:38 -0500, J. Bruce Fields wrote:
> > > > +static int gssx_dec_buffer(struct xdr_stream *xdr,
> > > > +			   gssx_buffer *buf)
> > > > +{
> > > > +	u32 length;
> > > > +	__be32 *p;
> > > > +
> > > > +	p = xdr_inline_decode(xdr, 4);
> > > > +	if (unlikely(p == NULL))
> > > > +		return -ENOSPC;
> > > > +
> > > > +	length = be32_to_cpup(p);
> > > > +	p = xdr_inline_decode(xdr, length);
> > >
> > > combine for efficiency with the 4 byte allocation above.
> > 
> > This was just a think-o on your part, right?  There's no way to decode the
> > whole thing in one gulp without knowing the length ahead of time.
> > Or am I missing something?
> 
> No. You are right, that was a brain-fart...
> 
> > > > +static int gssx_dec_option_array(struct xdr_stream *xdr,
> > > > +				 struct gssx_option_array *oa)
> > > > +{
> > > > +	struct svc_cred *creds;
> > > > +	u32 count, i;
> > > > +	__be32 *p;
> > > > +	int err;
> > > > +
> > > > +	p = xdr_inline_decode(xdr, 4);
> > > > +	if (unlikely(p == NULL))
> > > > +		return -ENOSPC;
> > > > +	count = be32_to_cpup(p++);
> > > > +	if (count != 0) {
> > > > +		/* we recognize only 1 currently: CREDS_VALUE */
> > > > +		oa->count = 1;
> > > > +
> > > > +		oa->data = kmalloc(sizeof(struct gssx_option), GFP_KERNEL);
> > >
> > > Sleeping kmallocs inside XDR encode/decode routines is strongly
> > > discouraged. Particularly so for something that can be preallocated.
> > 
> > And here: I don't mind doing that, but: there's no real problem here as long
> > as we're only calling this stuff synchronously, right?
> 
> If you can guarantee that it won't ever be called from rpciod, then fine.
> However anything that might end up being called from a rpciod context must at the very least guarantee that there are no __GFP_FS allocations, since those can deadlock the NFS client.

Got it, thanks

--b.
