Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757584AbaDHSY2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 14:24:28 -0400
Date: Tue, 8 Apr 2014 14:24:21 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Dr Fields James Bruce <bfields@fieldses.org>,
        NFS <linux-nfs@vger.kernel.org>,
        Adamson William Andros <androsadamson@gmail.com>,
        Lever Charles Edward <chuck.lever@oracle.com>
Subject: Re: v4.0 CB_COMPOUND authentication failures
Message-ID: <20140408142421.2a26eeaa@tlielax.poochiereds.net>
In-Reply-To: <61C732F7-A053-4293-AB54-07979E048F53@primarydata.com>
References: <20140408082140.340c1328@tlielax.poochiereds.net>
	<20140408123501.GA3532@fieldses.org>
	<20140408094903.33e42de2@tlielax.poochiereds.net>
	<20140408140333.GD3882@fieldses.org>
	<6CC79B2A-8AE2-4A36-BB57-380C2F9813C0@primarydata.com>
	<20140408144652.GE3882@fieldses.org>
	<ECD8245B-CDEE-442E-A41A-BECE08BEEDA1@primarydata.com>
	<20140408164024.GH3882@fieldses.org>
	<8F132114-F44C-449B-8EA8-331C67FCE813@primarydata.com>
	<20140408135512.2397d97f@tlielax.poochiereds.net>
	<61C732F7-A053-4293-AB54-07979E048F53@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Apr 2014 14:03:04 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Apr 8, 2014, at 13:55, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Tue, 8 Apr 2014 13:30:21 -0400
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> >> 
> >> On Apr 8, 2014, at 12:40, Dr Fields James Bruce <bfields@fieldses.org> wrote:
> >>> 
> >>> On Tue, Apr 08, 2014 at 12:22:51PM -0400, Trond Myklebust wrote:
> >>>> How is it not better just to rip out that hostname comparison in the
> >>>> back channel?
> >>> 
> >>> Rip it out entirely?
> >>> 
> >>> At that point anyone who can get a credential in the right realm can
> >>> send a recall.  RFC made this requirement to prevent that.
> >>> 
> >> 
> >> OK. Let’s examine what RFC3530 and RFC3530bis actually says here:
> >> 
> >>   Regardless of what security mechanism under RPCSEC_GSS is being used,
> >>   the NFS server MUST identify itself in GSS-API via a
> >>   GSS_C_NT_HOSTBASED_SERVICE name type.  GSS_C_NT_HOSTBASED_SERVICE
> >>   names are of the form:
> >> 
> >>     service@hostname
> >> 
> >>   For NFS, the "service" element is
> >> 
> >>     nfs
> >> 
> >>   Implementations of security mechanisms will convert nfs@hostname to
> >>   various different forms.  For Kerberos V5, the following form is
> >>   RECOMMENDED:
> >> 
> >>   nfs/hostname
> >> 
> >>   For Kerberos V5, nfs/hostname would be a server principal in the
> >>   Kerberos Key Distribution Center database.  This is the same
> >>   principal the client acquired a GSS-API context for when it issued
> >>   the SETCLIENTID operation, therefore, the realm name for the server
> >>   principal must be the same for the callback as it was for the
> >>   SETCLIENTID.
> >> 
> >> 
> >> So as I read the above, technically the client is supposed to read off the principal name that the server uses to authenticate itself to the SETCLIENTID and check that in the callback. Am I wrong?
> >> 
> >> If so, then the steps are:
> >> 
> >> 1) Modify process_krb5_upcall() and have the call to gss_inquire_context() also request the context acceptor name
> >> 2) Modify the rpc.gssd downcall to pass that name to the kernel in some format that allow us to retrieve it in the SETCLIENTID call.
> >> 3) Modify the comparison in check_gss_callback_principal()
> >> 
> >> 
> > 
> > Sounds about right, with #2 being the difficult part...
> > 
> > One possibility for that would be to add a new "acceptor" pipe in the
> > clnt?? dirs. Teach gssd to write to the acceptor name to that pipe
> > before doing the regular downcall.
> > 
> > The name written there could then be hung off of the clp. If userland
> > fails to write the name to the pipe before doing the downcall, we'll
> > simply do what we do today (use the cl_hostname).
> > 
> > Adding a new pipe is a bit of a pain, but it does sidestep the problem
> > of mismatched kernel and userland…
> > 
> 
> As far as I can tell, the downcall can be extended. Even the security context is an opaque, so its length is known. If we wanted to append a field after that, we could do so without affecting backward compatibility.
> 

Yeah, I think you're right. It looks like gss_pipe_downcall will just
ignore stuff that trails the security context. I'll have a look at
see whether tacking a new field on is feasible.

So in nfs4_proc_setclientid after the call, we can add some code that
copies the new acceptor field out of gss_cred->gss_cl_ctx, and attaches
it to a new field in the nfs_client. Alternately, I wonder if we could
get away with just replacing the clp->cl_hostname with that value?

-- 
Jeff Layton <jlayton@redhat.com>
