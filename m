Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16812 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755882Ab3GYOda (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jul 2013 10:33:30 -0400
Date: Thu, 25 Jul 2013 10:33:59 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Larry Keegan <lk@pfw.demon.co.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs client: Now you see it, now you don't (aka spurious ESTALE
 errors)
Message-ID: <20130725103359.7a0c44f8@corrin.poochiereds.net>
In-Reply-To: <1374762269.3868.6.camel@leira.trondhjem.org>
References: <20130725134515.67af44e2@cs3.al.itld>
	<20130725101143.6a22cb81@corrin.poochiereds.net>
	<1374762269.3868.6.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 25 Jul 2013 14:24:30 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-07-25 at 10:11 -0400, Jeff Layton wrote:
> 
> > What might be helpful is to do some network captures when the problem
> > occurs. What we want to know is whether the ESTALE errors are coming
> > from the server, or if the client is generating them. That'll narrow
> > down where we need to look for problems.
> 
> Hmm... Shouldn't ESTALE always be repackaged as ENOENT by the VFS, now
> that your patchset has gone upstream, Jeff?
> 

I don't think so...

On something path-based then that might make sense (or maybe we should
declare a new ERACE error like Al once suggested and return that). If
you're doing a write() on a fd that you previously opened but the inode
has disappeared on the server, then -ESTALE clearly seems valid.

There are other problematic cases too...

Suppose I do stat(".", ...); ? Does an -ENOENT error make sense at that point?

Also, since we only retry once on an ESTALE error, returning that is a
pretty clear indicator that you raced with some other metadata
operations. ENOENT is not as informative...

-- 
Jeff Layton <jlayton@redhat.com>
