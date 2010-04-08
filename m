From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: nfsd4 callback patches
Date: Thu,  8 Apr 2010 11:59:14 -0400
Message-ID: <1270742362-9375-1-git-send-email-bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52051 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932718Ab0DHP4z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 11:56:55 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1Nzu8Y-0002TX-Pp
	for linux-nfs@vger.kernel.org; Thu, 08 Apr 2010 11:59:22 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a second attempt at implementing a too-long-neglected nfsv4
feature which allows a client to change the callback parameters of a
preexisting client with a special setclientid.

The main motivation is actually 4.1, but haven't finished the later 4.1
patches (which add handling for SEQ4_STATUS_CB_PATH_* bits and the
minimum trunking support I think we can get away with).

The basic idea is to let a workqueue take over re-issuing an rpc
callback request when the original rpc client goes away.  We can then
change the callback client by creating a new rpc client, flushing the
workqueue, then destroying the old rpc client.

I'm applying the first 4 patches soon absent serious objections; the
others might need a little more time.

--b.
