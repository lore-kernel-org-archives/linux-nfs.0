Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:62889 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab2EUPoo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 11:44:44 -0400
Received: by wgbdr13 with SMTP id dr13so5123230wgb.1
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 08:44:43 -0700 (PDT)
Message-ID: <4FBA62E8.4080204@tonian.com>
Date: Mon, 21 May 2012 18:44:40 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-3.4-2012-05-21
References: <4EC13EEA.3030404@tonian.com> <4FB4E11D.2000202@tonian.com>
In-Reply-To: <4FB4E11D.2000202@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tree rebased onto v3.4, pnfs-all-3.4 branch created and tagged as pnfs-all-3.4-2012-05-21

The following patches were merged since pnfs-all-3.4-rc7-2012-05-17:

pnfsd:
  Benny Halevy     44f0a0b pnfsd: provide helper for xdr encoding of deviceid

pnfsd-exofs:
  Benny Halevy     713c0f1 pnfsd-exofs: use nfsd4_encode_deviceid

pnfsd-lexp:
  Boaz Harrosh     2d850da SQUASHME: pnfsd-lexp: Fix compiler warning when CONFIG_SUNRPC_DEBUG is not set
