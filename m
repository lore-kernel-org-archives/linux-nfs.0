From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Mount option parser support for multiple security flavors
Date: Fri, 21 Mar 2008 17:50:27 -0400
Message-ID: <20080321214854.13546.80458.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:12648 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755525AbYCUVup (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 17:50:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

You might find these useful as you finish SECINFO support.  These patches add
support to the NFS client's mount option parser for handling multiple security
flavors.  They should apply to your devel branch, and are appropriate for
2.6.26.

-- 
corporate:    <chuck dot lever at oracle dot com>
