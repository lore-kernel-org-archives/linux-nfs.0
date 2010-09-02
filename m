Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42576 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751078Ab0IBH5r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Sep 2010 03:57:47 -0400
Message-ID: <4C7F58F9.4080306@panasas.com>
Date: Thu, 02 Sep 2010 10:57:45 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] fix getdevice{info,list} xdr decode sizing
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

looks like encode_getdevice{info,list} went under the radar and they
do not update hdr->replen.

decode_getdeviceinfo_maxsz was completely screwed up so that twas fixed
along with the replen calculation for the deviceinfo's xdr_inline_pages.
