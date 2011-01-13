Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42759 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932610Ab1AMJYC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 04:24:02 -0500
Message-ID: <4D2EC4AC.9090205@panasas.com>
Date: Thu, 13 Jan 2011 11:23:56 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] decode_cb_op_status fix
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck, it looks like the following patch introduced a couple in
handling of the operation status.

85a5648 NFSD: Update XDR decoders in NFSv4 callback client

The first patch in this series fixes the bugs and the second
reintroduces the handling of nfserr into decode_cb_op_status
as it used to be in decode_cb_op_hdr, since I think it's simpler
with respect to the current usage (vs. theoretical generic use of
decode_cb_op_status to decode the status and return it in an output var).

Benny
