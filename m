From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [enctypes round 2: PATCH 05/26] rpc: gss: Add oid values to
	the gss_api mechanism structures
Date: Mon, 5 May 2008 11:22:51 -0400
Message-ID: <20080505152251.GD8259@fieldses.org>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu> <20080430164613.16010.22760.stgit@jazz.citi.umich.edu> <20080502213632.GK21918@fieldses.org> <1209764379.26234.11.camel@heimdal.trondhjem.org> <4d569c330805050728yf7040f3lb55bc08d4046e85e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48625 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888AbYEEPW7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 11:22:59 -0400
In-Reply-To: <4d569c330805050728yf7040f3lb55bc08d4046e85e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 05, 2008 at 10:28:18AM -0400, Kevin Coffman wrote:
> On Fri, May 2, 2008 at 5:39 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> >
> >  On Fri, 2008-05-02 at 17:36 -0400, J. Bruce Fields wrote:
> >  > On Wed, Apr 30, 2008 at 12:46:14PM -0400, Kevin Coffman wrote:
> >  > > From: Usha Ketineni <uketinen@us.ibm.com>
> >  > >
> >  > > On NFSV4 server side, these are required as part of the security
> >  > > triple(oid,qop,service) information being sent in the response of the
> >  > > SECINFO operation.
> >  >
> >  > Remind me why me need to do this?
> 
> The new downcall interface does not include the OID, so a static copy
> is eventually needed.

Before the patch you can get e.g. the krb5 oid from
gss_kerberos_mech->gm_oid; afterwards it's also available as krb5_oid.

If anything the former seems more useful to the downcall code, as it can
be used without requiring some particular knowledge of the krb5 code (it
only needs to know the gss-level gss_api_mech structure).

I have a feeling this patch is just a relic from a time before we had
any oid's here at all?

--b.

> I agree this description doesn't indicate that.
>  This was one of the encryption patches I started with.  Not an
> excuse, though.
> 
> >  ...and why we need to let NFSd have intimate knowledge of the gss_api
> >  mechanism structures. It would be _very_ nice to wrap all this up into
> >  some helper at the SUNRPC level with no dependencies on the RPCSEC_GSS
> >  code.
> 
> Agreed.  Should we have a generic definition for an OID structure, or
> continue to use xdr_netobj?  (It is generally assumed in GSS-API that
> upper-level software is aware of the OID structure.)
> 
> The gssapi spec (rfc2744) defines an oid as:
> 
> typedef struct gss_OID_desc_struct {
>     OM_uint32  length;
>     void  *elements;
> } gss_OID_desc, *gss_OID;
> 
> So a kernel definition might look like:
> 
> struct gss_oid {
>     u32  length;
>     void *data;   /* or keep the name "elements" */
> };
> 
> So the new interface would look something like one of the following?
> 
> int gss_mech_get_oid(struct gss_api_mech *gm, struct xdr_netobj **oid);
> 
> or
> 
> int gss_mech_get_oid(struct gss_api_mech *gm, struct gss_oid **oid);
