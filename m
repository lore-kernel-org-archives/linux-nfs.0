From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [pnfs] [PATCH 1/1] nfs41: resolve some race conditions with
 queued SEQUENCE operations when unmounting
Date: Wed, 14 Oct 2009 17:53:18 -0400
Message-ID: <1255557198.6308.36.camel@heimdal.trondhjem.org>
References: <1255561029-2925-1-git-send-email-batsakis@netapp.com>
	 <1255555809.6308.34.camel@heimdal.trondhjem.org>
	 <5e24e8930910141450h11e677bbr17ebe3441a8742d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexandros Batsakis <batsakis@netapp.com>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:57480 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755401AbZJNVx7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2009 17:53:59 -0400
In-Reply-To: <5e24e8930910141450h11e677bbr17ebe3441a8742d8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-10-14 at 14:50 -0700, Alexandros Batsakis wrote:
> a) nfs41_sequence_done() called after destroy_session() that leads to
> a NULL pointer dereference
> b) a BADSESSION reply to a sequence operation triggers a
> reset_session() at the same time with destroy_session() (called by
> umount) that leads to another NULL pointer dereference.

This would mean that nfs41_sequence_done is being called _after_ the
nfs_client (and hence the session) has been destroyed. That sounds like
the real bug that needs to be fixed.

Cheers
  Trond

