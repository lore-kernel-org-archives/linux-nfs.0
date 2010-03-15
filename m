From: steved@redhat.com
Subject: [PATCH 00/22] Add new enctypes for gss_krb5 (Round 4)
Date: Mon, 15 Mar 2010 08:20:05 -0400
Message-ID: <1268655627-18712-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:41134 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964876Ab0CON0B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 09:26:01 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Nr9HX-00009j-RX
	for linux-nfs@vger.kernel.org; Mon, 15 Mar 2010 08:20:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

This is round 4 of the Kevin Coffman's patches that added three
additional encryption types to the rpcsec_gss kernel code.
Here is a pointer to Kevin's last posting
    http://marc.info/?l=linux-nfs&m=121010783625159&w=2

These patches were tested a this year's connectathon in which
not issues were found. 

There are also a three nfs-utils patches that needed to be applied
to the gssd daemons to complete this. Those will be posted asap...

Please consider including these in the next kernel release...

steved.

Kevin Coffman (21):
  gss_krb5: introduce encryption type framework
  Don't expect blocksize to always be 8 when calculating padding
  gss_krb5: gss_krb5: split up functions in preparation of adding new
    enctypes
  gss_krb5: prepare for new context format
  gss_krb5: introduce encryption type framework
  gss_krb5: add ability to have a keyed checksum (hmac)
  gss_krb5: import functionality to derive keys into the kernel
  gss_krb5: handle new context format from gssd
  gss_krb5: add support for triple-des encryption
  Add new pipefs file indicating which Kerberos enctypes the kernel
    supports
  Update pipefs file indicating which Kerberos enctypes the kernel
    supports
  xdr: Add an export for the helper function write_bytes_to_xdr_buf()
  gss_krb5: add support for new token formats in rfc4121
  gss_krb5: add remaining pieces to enable AES encryption support
  gss_krb5: Update pipefs file
  arcfour-hmac support
  Save the raw session key in the context
  More arcfour-hmac support
  Use confounder length in wrap code
  Add support for rc4-hmac encryption
  Update the pipefs file

Peter Staubach (1):
  Fixed memory leak in gss_import_v1_context()

 include/linux/sunrpc/gss_krb5.h       |  184 ++++++++-
 net/sunrpc/auth_gss/Makefile          |    2 +-
 net/sunrpc/auth_gss/auth_gss.c        |   14 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  715 ++++++++++++++++++++++++++++++++-
 net/sunrpc/auth_gss/gss_krb5_keys.c   |  335 +++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |  581 +++++++++++++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_seal.c   |  156 ++++++--
 net/sunrpc/auth_gss/gss_krb5_seqnum.c |   83 ++++-
 net/sunrpc/auth_gss/gss_krb5_unseal.c |  113 +++++-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |  476 +++++++++++++++++++---
 net/sunrpc/auth_gss/gss_mech_switch.c |   14 +
 net/sunrpc/auth_gss/svcauth_gss.c     |   15 +
 net/sunrpc/rpc_pipe.c                 |   31 ++
 net/sunrpc/xdr.c                      |    1 +
 14 files changed, 2553 insertions(+), 167 deletions(-)
 create mode 100644 net/sunrpc/auth_gss/gss_krb5_keys.c

