From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [enctypes round 3: PATCH 00/24] Add new enctypes for gss_krb5
Date: Wed, 7 May 2008 10:41:59 -0400
Message-ID: <20080507144159.GA10599@fieldses.org>
References: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38382 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758718AbYEGOmB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2008 10:42:01 -0400
In-Reply-To: <20080506210156.3770.95914.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 06, 2008 at 05:03:28PM -0400, Kevin Coffman wrote:
> This is round 3.
> 
> This set of patches adds kernel support for triple-DES (des3-cbc-sha1),
> arcfour (rc4-hmac), and AES (aes128-cts, aes256-cts) encryption to the
> kernel's Kerberos rpcsec_gss code.
> 
> These are currently based on Trond's tree as of 05/06/08.
> 
> This still includes the first couple of patches you've already applied
> (I couldn't find them in your public git, so I assume I'm missing
> something, or they are applied to your local development git, or
> I'm still missing something...)

No, that was my fault, sorry--I applied them, then didn't push them out
immediately.  They should be there now.

I may not take a look at the rest of these till after connectathon (but
I'll try if I get a chance).

--b.

> This round removes the two patches that use global OIDs.  Instead,
> krb5 contexts created from the new v2 context format from gssd copy
> the OID from the gss_kerberos_mech structure.
> 
> Two issues remain:
> 
> 1) The patch to add krb5_info will eventually be replaced with an
> updated upcall which will include the supported enctype information.
> I have split out these portions of the patches to (hopefully) make
> that transition easier.
> 
> 2) There is currently no code to handle the possiblity of rotated
> data in the version two tokens.  I don't expect we'll see rotated
> data in normal operation, but this should be done eventually for
> completeness.
> 
> There are two nfs-utils patches required with this.  The first reads
> and parses the list of kernel supported enctypes.  The second
> implements the new context format from user-land to kernel.
> These are included in the recent nfs-utils-1.1.2-CITI_NFS4_ALL-1 patches.
> 
> 
> ------------------
> 
> Note: for AES support, the following patch for MIT Kerberos is needed
> to get the right key when there is an acceptor_subkey.  [mea culpa]
> 
> This fix is scheduled to be included in MIT release 1.6.4, currently
> in beta testing.
> 
> This patch should also apply to releases 1.4.0 to 1.6.3.
> 
> Index: src/lib/gssapi/krb5/lucid_context.c
> ===================================================================
> --- src/lib/gssapi/krb5/lucid_context.c (revision 20174)
> +++ src/lib/gssapi/krb5/lucid_context.c (revision 20175)
> @@ -231,7 +231,7 @@
>                                         &lctx->cfx_kd.ctx_key)))
>             goto error_out;
>         if (gctx->have_acceptor_subkey) {
> -           if ((retval = copy_keyblock_to_lucid_key(gctx->enc,
> +           if ((retval = copy_keyblock_to_lucid_key(gctx->acceptor_subkey,
>                                         &lctx->cfx_kd.acceptor_subkey)))
>                 goto error_out;
>             lctx->cfx_kd.have_acceptor_subkey = 1;
