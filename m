Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49017 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758830Ab3BGQzK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 11:55:10 -0500
Date: Thu, 7 Feb 2013 11:55:09 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Refactor nfsd4_do_encode_secinfo()
Message-ID: <20130207165509.GM3222@fieldses.org>
References: <20130201220308.13518.82164.stgit@seurat.1015granger.net>
 <20130207150213.GC3222@fieldses.org>
 <87316F41-4E5E-473C-A372-0AFC6721A355@oracle.com>
 <20130207162308.GI3222@fieldses.org>
 <F0DAA0C6-DBA2-457B-8C68-13A2BC3CB4AC@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F0DAA0C6-DBA2-457B-8C68-13A2BC3CB4AC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 07, 2013 at 11:26:43AM -0500, Chuck Lever wrote:
> 
> On Feb 7, 2013, at 11:23 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Thu, Feb 07, 2013 at 10:58:25AM -0500, Chuck Lever wrote:
> >> 
> >> On Feb 7, 2013, at 10:02 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> 
> >>> On Fri, Feb 01, 2013 at 05:43:44PM -0500, Chuck Lever wrote:
> >>>> Clean up.  This matches a similar API for the client side, and
> >>>> keeps ULP fingers out the of the GSS mech switch.
> >>>> 
> >>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >>>> Acked-by: J. Bruce Fields <bfields@redhat.com>
> >>>> ---
> >>>> 
> >>>> Bruce-
> >>>> 
> >>>> This version of the patch follows the existing logic in
> >>>> nfsd4_do_encode_secinfo(): If the RPC layer can't find GSS info
> >>>> that matches an export security flavor, it assumes the flavor is
> >>>> not a GSS pseudoflavor, and simply puts it on the wire.
> >>>> 
> >>>> However, if the below XDR encoding logic is given a legitimate GSS
> >>>> pseudoflavor but the RPC layer says it does not support that
> >>>> pseudoflavor for some reason, then we leak GSS pseudoflavor numbers
> >>>> onto the wire.
> >>>> 
> >>>> I confirmed this happens by blacklisting rpcsec_gss_krb5, then
> >>>> attempted a client transition from the pseudo-fs to a Kerberos-only
> >>>> share.  The client received a flavor list containing the Kerberos
> >>>> pseudoflavor numbers, rather than GSS tuples.
> >>>> 
> >>>> The encoder logic can check that each pseudoflavor is less than
> >>>> MAXFLAVOR before writing it into the buffer, to prevent this.  But
> >>>> after "nflavs" is written into the XDR buffer, the encoder can't
> >>>> skip writing flavor information into the buffer when it discovers
> >>>> the RPC layer doesn't support that flavor.
> >>>> 
> >>>> Is there some way of writing "nflavs" into the XDR buffer after
> >>>> the loop that writes the flavor information is complete?
> >>> 
> >>> Yes, you can save a pointer and then go back and fill that in--see
> >>> encode_fattr for an example.
> >> 
> >> Thanks, I will submit an additional patch that describes this issue and fixes it.
> >> 
> >> I asked David Noveck, as one of the authors of RFC 3530, whether an NFS server should return a zero-length flavor list or an error if SECINFO can't find any flavors a client is allowed to use. His opinion was to return NFS4_OK and a zero-length flavor list.
> > 
> > Fine with me for this code.
> 
> OK, will go with that.
> 
> > (In practice though we should probably be warning somewhere (exportfs?)
> > if somebody creates an export like that.)
> 
> The problem can also arise because gssd isn't running or auth_rpcgss.ko or rpcsec_gss_krb5.ko are not loadable for some reason.  In other words, an empty flavor list might also be the result of a transient server misconfiguration.

OK.  Do you think the kernel could help by providing a once-only warning
in such a case?  (Or in the case when we're not able to find support for
a security flavor set on the export.)

--b.
