From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/8] NLM client improvements for 2.6.26
Date: Thu, 03 Apr 2008 18:39:21 -0400
Message-ID: <20080403223921.12713.71396.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8113 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869AbYDCW5z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2008 18:57:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series applies on top of the 'devel' branch of the NFS
client git tree (git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git).

Most of the series is attempting to fix up the ability to interrupt NLM
locking requests, and to eliminate an existing bug whereby a non-fatal
signal to a process may cause it to set a local lock (one that doesn't
exist on the server) that doesn't get cleared.

The series also includes updated versions of the patches that I
suggested to fix the problem that Peter Staubach reported w.r.t.
UNLOCK requests being sent asynchronously when a process exits. The
previous patches had the problem that they also made the GRANTED
callback from the server synchronous, which is undesirable.

Finally, the last patch in the series is really more of a contination
of the generic credentials patches. It uses the generic credential to
ensure that NLM requests are authenticated to the same identity as the
open() call used.

Cheers
  Trond

