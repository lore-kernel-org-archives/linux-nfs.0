Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53739 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439AbcDJLos (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Apr 2016 07:44:48 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5EC04C057EC9
	for <linux-nfs@vger.kernel.org>; Sun, 10 Apr 2016 11:44:47 +0000 (UTC)
Received: from [10.10.49.92] (vpn-49-92.rdu2.redhat.com [10.10.49.92])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u3ABikCS026560
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Sun, 10 Apr 2016 07:44:46 -0400
Date: Sun, 10 Apr 2016 07:44:45 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: nfsd delays between svc_recv and gss_check_seq_num
Message-ID: <alpine.OSX.2.19.9992.1604100724080.44797@planck>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My client hangs on xfstests generic/074 on a krb5 mount, and I've found that
the linux server is silently discarding one or more RPCs because the GSS
sequence numbers are outside the sequence window.

The reason is that sometimes one of the nfsd threads takes a long time
between receiving the RPC and then checking if the sequence is within the
window.  That delay allows the other nfsd threads to quickly move the window
forward out of range.

If the server discards the RPC then that causes then the client to wait
forever for a response or until the connection is reset.

By inserting tracepoints, I think I found two sources of delay:

 1) gss_svc_searchbyctx() uses dup_to_netobj() which has a kmemdup with
GFP_KERNEL.  It does this because presumabely it doesn't know how big the
context handle should be.

 2) gss_verify_mic() uses make_checksum() which eventually gets to
crypto_alloc_hash() with GFP_KERNEL.

For the first delay, can we assume the context handles are all going to be
the same size?  It looks like the handle is assigned by the server, so it
seems like we should be able to know beforehand how large they are.

For the second allocation -- I haven't thrown a lot of thought into what
could be done to fix it.. seems a bit tricker.  I'll think about both of
these a bit more, but I thought in the meantime to ask if anyone has
thoughts about this problem.  Maybe we can to the sequence check before
verify_mic -- but then a message that fails verification could flip the
sequence bit..

Ben
