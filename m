Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934111Ab1JaWYh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 18:24:37 -0400
Subject: Re: [PATCH 1/8] pnfs-obj: Remove redundant EOF from
 objlayout_io_state
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Brent Welch <welch@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Date: Mon, 31 Oct 2011 18:24:17 -0400
In-Reply-To: <1320097506-734-1-git-send-email-bharrosh@panasas.com>
References: <4EAF146D.5060507@panasas.com>
	 <1320097506-734-1-git-send-email-bharrosh@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320099857.10028.6.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-31 at 14:45 -0700, Boaz Harrosh wrote: 
> The EOF calculation was done on .read_pagelist(), cached
> in objlayout_io_state->eof, and set in objlayout_read_done()
> into nfs_read_data->res.eof.
> 
> So set it directly into nfs_read_data->res.eof and avoid
> the extra member.
> 
> This is a slight behaviour change because before eof was
> *not* set on an error update at objlayout_read_done(). But
> is that a problem? Is Generic layer so sensitive that it
> will miss the error IO if eof was set? From my testing
> I did not see such a problem.

That would probably be because the object layout will be recalled if the
file size changes on the server. If that is not the case, then you do
need eof detection...

> Which brings me to a more abstract problem. Why does the
> LAYOUT driver needs to do this eof calculation? .i.e we
> are inspecting generic i_size_read() and if spanned by
> offset + count which is received from generic layer we set
> eof. It looks like all this can/should be done in generic
> layer and not at LD. Where does NFS and files-LD do it?
> It looks like it can be promoted.

No it can't. The eof flag is returned as part of the READ4resok
structure (i.e. it is part of the READ return value) on both
read-through-mds and files-type layout reads. Basically, it allows the
server to tell you _why_ it returned a short read.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

