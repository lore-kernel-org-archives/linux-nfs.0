Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:50526 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757299Ab0JUT0k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 15:26:40 -0400
Subject: [PATCH] xs_bind retry binding forever 
To: Trond.Myklebust@netapp.com
From: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 21 Oct 2010 13:33:32 -0500
Message-ID: <20101021183203.12776.28469.stgit@lady3jane.americas.sgi.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Trond,

    I've been working on a bug related to autofs where a nfs mount returns EIO
    in the middle of a job at which point things start to fail.  It turns out
    the machine isn't running nscd and that is causing a large number of
    reserved source ports to be used over localhost and they crowd out the nfs
    client.  Prior to commit 67a391d72ca7efb387c30ec761a487e50a3ff085 this was
    not a problem because we retried forever until we got a reserved source
    port.  It's ok to say 'use nscd', but in many cases nscd is not turned on
    by default so I'd like to propose we revert to the previous behavior: retry
    binding forever.

Thanks,
	Ben

---

Ben Myers (1):
      xs_bind retry binding forever


 net/sunrpc/xprtsock.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

-- 
