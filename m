From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/3] nfsd41: fix callback minorversion
Date: Sun, 29 Mar 2009 22:09:12 +0300
Message-ID: <49CFC758.6030808@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27012 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750917AbZC2TJd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Mar 2009 15:09:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following three patches get rid of the server's use of cl_private
by passing the minorversion for callbacks via struct nfs4_rpc_args

I'd like to squash them into the nfsd41-for-2.6.30 series
and resend (v3)

Benny

[PATCH 1/3] SQUASHME: get callback minorversion from fore channel's
[PATCH 2/3] SQUASHME: nfsd41: use nfsd4_cb_sequence for callback minorversion
[PATCH 3/3] SQUASHME: Revert "sunrpc: add cl_private field to struct rpc_clnt"
