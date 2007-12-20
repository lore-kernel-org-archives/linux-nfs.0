From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Don't touch rpc_xprt directly in lockd
Date: Thu, 20 Dec 2007 15:03:51 -0500
Message-ID: <20071220195600.3358.41189.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:64904 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbXLTUEA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2007 15:04:00 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Here's a set of patches that remove lockd's dependence on the rpc_xprt.prot
field in nlmclnt_proc().

There are a few reasons to remove this dependence, including:

1.  The NFS client is now fully in control of selecting which transport
    protocol is chosen for the sideband NLM protocol (use UDP only if NFS
    over UDP is specified; otherwise TCP is used).

2.  Looking at fields in the rpc_xprt structure in an upper-level protocol
    implementation is a layering violation.

3.  The rpc_xprt.prot field is overloaded -- it's used to control RPC binding
    as well as which transport protocol is used for sideband protocols.

4.  Removing the nlmclnt_lookup_host() call from nlmclnt_proc() eliminates
    work that is unnecessarily repeated for each NLM request.

This patch series should replace the four I sent you last week for review.
Please consider them for 2.6.25.

-- 
corporate:    <chuck dot lever at oracle dot com>
