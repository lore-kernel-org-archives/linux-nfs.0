From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: What is the purpose of those put_rpccred() statements?
Date: Fri, 23 Oct 2009 15:56:11 -0400
Message-ID: <1256327771.3238.51.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>,
	William Andros Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:36100 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750882AbZJWT4O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Oct 2009 15:56:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm finding a bunch of random calls of the form
   put_rpccred(task->tk_msg.rpc_cred);

in functions like nfs4_renew_done(), nfs41_sequence_call_done() with
apparently no corresponding get_rpccred(). Could you please enlighten me
what they are all about? They're not mentioned at all in the changelogs
of commits 29fba38b, and fc01cea9...

Trond

