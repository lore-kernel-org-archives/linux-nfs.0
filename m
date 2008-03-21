From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] Improvements to RPC debugging infrastructure
Date: Fri, 21 Mar 2008 18:42:57 -0400
Message-ID: <20080321224130.18966.48529.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:26590 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975AbYCUWnO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 18:43:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Here are a handful of potential improvements to the RPC client's debugging
infrastructure.  Please consider these for 2.6.26.

-- 
corporate:    <chuck dot lever at oracle dot com>
