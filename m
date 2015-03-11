Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:28339
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752267AbbCKREQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2015 13:04:16 -0400
From: Julia Lawall <Julia.Lawall@lip6.fr>
To: linux-arm-kernel@lists.infradead.org
Cc: kernel-janitors@vger.kernel.org, linux-edac@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-wireless@vger.kernel.org,
        linux-crypto@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
        linux-wpan@vger.kernel.org, target-devel@vger.kernel.org
Subject: [PATCH 0/15] don't export static symbol
Date: Wed, 11 Mar 2015 17:56:22 +0100
Message-Id: <1426092997-30605-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches remove EXPORT_SYMBOL or EXPORT_SYMBOL_GPL declarations on
static functions.

This was done using the following semantic patch:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
type T;
identifier f;
@@

static T f (...) { ... }

@@
identifier r.f;
declarer name EXPORT_SYMBOL;
@@

-EXPORT_SYMBOL(f);

@@
identifier r.f;
declarer name EXPORT_SYMBOL_GPL;
@@

-EXPORT_SYMBOL_GPL(f);
// </smpl>

