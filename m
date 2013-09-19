Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51007 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002Ab3ISP12 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 11:27:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: stable@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: gss-proxy fixes for 3.11.x
Date: Thu, 19 Sep 2013 11:27:18 -0400
Message-Id: <1379604442-27724-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following commits should have been cc'd to stable for 3.11.x:

	778e512bb1d3315c6b55832248cd30c566c081d7 rpc: clean up decoding of gssproxy linux creds
	6a36978e6931e6601be586eb313375335f2cfaa3 rpc: comment on linux_cred encoding, treat all as unsigned
	9dfd87da1aeb0fd364167ad199f40fe96a6a87be rpc: fix huge kmalloc's in gss-proxy
	d4a516560fc96a9d486a9939bcb567e3fdce8f49 rpc: let xdr layer allocate gssproxy receieve pages

--b.
