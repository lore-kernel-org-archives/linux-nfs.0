Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:43945 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755257AbZFQQyn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2009 12:54:43 -0400
Date: Wed, 17 Jun 2009 12:54:42 -0400
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Steve Dickson <steved@redhat.com>, Tom Talpey <tmtalpey@gmail.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Link performance over NFS degraded in RHEL5. -- was :
	Read/Write NFS I/O performance degraded by FLUSH_STABLE page
	flushing
Message-ID: <20090617165442.GE21311@fieldses.org>
References: <4A291DE3.2070105@RedHat.com> <1244209956.5410.33.camel@heimdal.trondhjem.org> <4A29243F.8080008@RedHat.com> <20090605160544.GE10975@fieldses.org> <1244219715.5410.40.camel@heimdal.trondhjem.org> <20090615230801.GA18504@fieldses.org> <99d4545537613ce76040d3655b78bdb7.squirrel@neil.brown.name> <20090616003357.GB19396@fieldses.org> <02ada87c636e1088e9365a3cbea301e7.squirrel@neil.brown.name> <20090616005558.GC19396@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20090616005558.GC19396@fieldses.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jun 15, 2009 at 08:55:58PM -0400, bfields wrote:
> Whoops--actually, it's the opposite problem: a bugfix patch that went
> upstream removed this, and I didn't merge that back into my for-2.6.31
> branch.  OK, time to do that, and then this is all much simpler....
> Thanks for calling my attention to that!

Having fixed that... the following is what I'm applying (on top of
Trond's).

--b.
