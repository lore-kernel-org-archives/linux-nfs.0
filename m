From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] NSM clean-ups for 2.6.26
Date: Fri, 14 Mar 2008 14:25:24 -0400
Message-ID: <20080314182312.30171.49619.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:44403 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756718AbYCNSZn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:25:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's the last set of "non-controversial" patches.  I have a few more to
post, but will wait until we're happy with the ones I sent this afternoon.

These patches clean up the XDR encoding routines for SM_MON.  They are a
pre-requisite for IPv6 support, and should be safe to include in 2.6.26.

-- 
corporate:    <chuck dot lever at oracle dot com>
