Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:55121 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753206Ab0CQRDL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:03:11 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweC-0003fC-If
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:09 -0400
From: steved@redhat.com
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/23] Add new enctypes for gss_krb5 (Round 5)
Date: Wed, 17 Mar 2010 13:02:45 -0400
Message-Id: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Steve Dickson <steved@redhat.com>

Here is the next round of Kevin Coffman's encryption patches.
This series includes all of the review comments from the 
previous posting except for one. 

Its the question as to why there were two occurrences of
GSS_KRB5_TOK_HDR_LEN define in the GSS_KRB5_MAX_SLACK_NEEDED
macro. Since Kevin is traveling and the reason didn't seem 
obvious plus I didn't see it as being a showstopper (due to
all the recent testing), I decided to proceed as. If later 
its deemed a supplemental patch is needed, I'll post the patch

Again, the details of the original patches are at:
 http://marc.info/?l=linux-nfs&m=121010783625159&w=2

steved.

J. Bruce Fields (1):
  gss_krb5: Don't expect blocksize to always be 8 when calculating
    padding

Kevin Coffman (21):
  gss_krb5: Introduce encryption type framework
  gss_krb5: Added and improved code comments
  gss_krb5: split up functions in preparation of adding new enctypes
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
  gssd_krb5: arcfour-hmac support
  gss_krb5: Save the raw session key in the context
  gssd_krb5: More arcfour-hmac support
  gss_krb5: Use confounder length in wrap code
  gss_krb5: Add support for rc4-hmac encryption
  Update the pipefs file

Peter Staubach (1):
  Fixed a typo in gss_verify_mic_v2()

 include/linux/sunrpc/gss_krb5.h       |  183 +++++++++-
 net/sunrpc/auth_gss/Makefile          |    2 +-
 net/sunrpc/auth_gss/auth_gss.c        |   14 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  697 ++++++++++++++++++++++++++++++++-
 net/sunrpc/auth_gss/gss_krb5_keys.c   |  335 ++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c   |  582 +++++++++++++++++++++++++--
 net/sunrpc/auth_gss/gss_krb5_seal.c   |  155 ++++++--
 net/sunrpc/auth_gss/gss_krb5_seqnum.c |   83 ++++-
 net/sunrpc/auth_gss/gss_krb5_unseal.c |  113 +++++-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |  473 ++++++++++++++++++++---
 net/sunrpc/auth_gss/gss_mech_switch.c |   14 +
 net/sunrpc/auth_gss/svcauth_gss.c     |   15 +
 net/sunrpc/rpc_pipe.c                 |   27 ++
 net/sunrpc/xdr.c                      |    1 +
 14 files changed, 2527 insertions(+), 167 deletions(-)
 create mode 100644 net/sunrpc/auth_gss/gss_krb5_keys.c

