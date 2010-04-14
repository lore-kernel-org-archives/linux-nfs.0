Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48907 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756527Ab0DNRhR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:17 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawJu021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:36:58 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/22] Add support for more RPCSEC_GSS/krb5 enctypes
Date: Wed, 14 Apr 2010 13:36:36 -0400
Message-Id: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The following patches have been queued up in the nfs-for-2.6.35 branch
on git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.

Cheers
  Trond


J. Bruce Fields (1):
  gss_krb5: Don't expect blocksize to always be 8 when calculating
    padding

Kevin Coffman (17):
  gss_krb5: Introduce encryption type framework
  gss_krb5: Added and improved code comments
  gss_krb5: split up functions in preparation of adding new enctypes
  gss_krb5: prepare for new context format
  gss_krb5: introduce encryption type framework
  gss_krb5: add ability to have a keyed checksum (hmac)
  gss_krb5: import functionality to derive keys into the kernel
  gss_krb5: handle new context format from gssd
  gss_krb5: add support for triple-des encryption
  xdr: Add an export for the helper function write_bytes_to_xdr_buf()
  gss_krb5: add support for new token formats in rfc4121
  gss_krb5: add remaining pieces to enable AES encryption support
  gssd_krb5: arcfour-hmac support
  gss_krb5: Save the raw session key in the context
  gssd_krb5: More arcfour-hmac support
  gss_krb5: Use confounder length in wrap code
  gss_krb5: Add support for rc4-hmac encryption

Trond Myklebust (4):
  gss_krb5: Add upcall info indicating supported kerberos enctypes
  gss_krb5: Advertise triple-des enctype support in the rpcsec_gss/krb5
    upcall
  gss_krb5: Advertise AES enctype support in the rpcsec_gss/krb5 upcall
  gss_krb5: Advertise rc4-hmac enctype support in the rpcsec_gss/krb5
    upcall

 include/linux/sunrpc/gss_api.h        |    2 +
 include/linux/sunrpc/gss_krb5.h       |  183 +++++++++-
 net/sunrpc/auth_gss/Makefile          |    2 +-
 net/sunrpc/auth_gss/auth_gss.c        |   22 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  697 ++++++++++++++++++++++++++++++++-
 net/sunrpc/auth_gss/gss_krb5_keys.c   |  335 ++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |  582 +++++++++++++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_seal.c   |  155 ++++++--
 net/sunrpc/auth_gss/gss_krb5_seqnum.c |   83 ++++-
 net/sunrpc/auth_gss/gss_krb5_unseal.c |  113 +++++-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |  404 ++++++++++++++++---
 net/sunrpc/auth_gss/gss_mech_switch.c |   14 +
 net/sunrpc/auth_gss/svcauth_gss.c     |   15 +
 net/sunrpc/xdr.c                      |    1 +
 14 files changed, 2439 insertions(+), 169 deletions(-)
 create mode 100644 net/sunrpc/auth_gss/gss_krb5_keys.c

