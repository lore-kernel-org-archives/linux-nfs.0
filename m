From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 3: PATCH 00/24] Add new enctypes for gss_krb5
Date: Tue, 06 May 2008 17:03:28 -0400
Message-ID: <20080506210156.3770.95914.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:13946 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754282AbYEFVD3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:03:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is round 3.

This set of patches adds kernel support for triple-DES (des3-cbc-sha1),
arcfour (rc4-hmac), and AES (aes128-cts, aes256-cts) encryption to the
kernel's Kerberos rpcsec_gss code.

These are currently based on Trond's tree as of 05/06/08.

This still includes the first couple of patches you've already applied
(I couldn't find them in your public git, so I assume I'm missing
something, or they are applied to your local development git, or
I'm still missing something...)

This round removes the two patches that use global OIDs.  Instead,
krb5 contexts created from the new v2 context format from gssd copy
the OID from the gss_kerberos_mech structure.

Two issues remain:

1) The patch to add krb5_info will eventually be replaced with an
updated upcall which will include the supported enctype information.
I have split out these portions of the patches to (hopefully) make
that transition easier.

2) There is currently no code to handle the possiblity of rotated
data in the version two tokens.  I don't expect we'll see rotated
data in normal operation, but this should be done eventually for
completeness.

There are two nfs-utils patches required with this.  The first reads
and parses the list of kernel supported enctypes.  The second
implements the new context format from user-land to kernel.
These are included in the recent nfs-utils-1.1.2-CITI_NFS4_ALL-1 patches.


------------------

Note: for AES support, the following patch for MIT Kerberos is needed
to get the right key when there is an acceptor_subkey.  [mea culpa]

This fix is scheduled to be included in MIT release 1.6.4, currently
in beta testing.

This patch should also apply to releases 1.4.0 to 1.6.3.

Index: src/lib/gssapi/krb5/lucid_context.c
===================================================================
--- src/lib/gssapi/krb5/lucid_context.c (revision 20174)
+++ src/lib/gssapi/krb5/lucid_context.c (revision 20175)
@@ -231,7 +231,7 @@
                                        &lctx->cfx_kd.ctx_key)))
            goto error_out;
        if (gctx->have_acceptor_subkey) {
-           if ((retval = copy_keyblock_to_lucid_key(gctx->enc,
+           if ((retval = copy_keyblock_to_lucid_key(gctx->acceptor_subkey,
                                        &lctx->cfx_kd.acceptor_subkey)))
                goto error_out;
            lctx->cfx_kd.have_acceptor_subkey = 1;
