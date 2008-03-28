From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/2] asynchronous unlock on exit
Date: Fri, 28 Mar 2008 16:12:29 -0400
Message-ID: <20080328201229.18158.52437.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60292 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371AbYC1UTf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2008 16:19:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Peter,

The following patchsets takes up the theme from the NLM patch that you
sent me a couple of weeks ago, and re-implements your fix in terms
that are closer to the existing NFSv4 implementation (which you
said was fine).

Cheers
  Trond

---
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
