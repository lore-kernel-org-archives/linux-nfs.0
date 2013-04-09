Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-vbr2.xs4all.nl ([194.109.24.22]:2355 "EHLO
	smtp-vbr2.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755740Ab3DIMqM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2013 08:46:12 -0400
Date: Tue, 9 Apr 2013 14:46:06 +0200
From: Miquel van Smoorenburg <mikevs@xs4all.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] RFC: nfs client: lower number of NFS ops in some
 circumstances
Message-ID: <20130409124600.GA15201@xs4all.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These NFS client patches are posted as an RFC - request for comment.

The idea behind these patches is to make it possible to cut down on
the number of NFS operations used when opening a file in certain
circumstances and environments (esp. mostly-readonly environments).

1/2: "noaccesscheck" mount option

     If this option is enabled, the nfs client will not send any
     NFS ACCESS calls to the server, except for UID 0. For all other
     uids, access is checked locally using generic_permission().

2/2: "sloppycto=N" mount option

     This mount option is a bit like like "nocto" - it suppresses
     a GETATTR call when a file is opened if we still have valid
     attribute data in the cache. The difference is that 1) we
     only do this for files that are opened read-only and 2) only
     when the last attribute update was 'N' seconds or less ago.

We've been using these patches in production for a couple of months.

Background:

On our webhosting setup, all our customers data is stored on
NFS server appliances. A cluster of linux webservers mounts those
volumes (using NFSv3 over TCP, Unix auth) and serves HTTP,
using a reasonably standard apache setup.

That works pretty well, the problem is our customers like to run
"modern" PHP CMSes like Joomla that are built 'modular' and like to
include hundreds of PHP files to generate just one page. To add
insult to injury, PHP itself stat()s every file before it open()s it.

This means for every pageview with such a CMS we get hundreds of:

stat():   GETATTR
open():   ACCESS + GETATTR (for close-to-open consistency).

Obviously we also get a few hundred read() requests, but only
the very first time, and the content of these files is cached
pretty well after that.

If a second pageview is within the nfsi->attrtimeo timeout, we
may see:

stat():   (GETATTR cached)
open():   ACCESS + GETATTR

or

stat():   (GETATTR cached)
open():   (ACCESS cached) + GETATTR

But after the attribute timeout it's 3 NFS operations again.

With the 'noaccesscheck' mount option, this gets reduced to two operations:

stat():   GETATTR
open():   GETATTR

And after adding the 'sloppycto=3' mount option it becomes

stat():   GETATTR
open():   (GETATTR cached)

This really cuts down on the number of NFS operations. That's good
for us, as the NFS server solution we're using appears to support a
high, but still limited maximum number of NFS ops/sec.

I can think of a few enhancements/adjustments to these patches:

- a clearer name than "noaccesscheck" ?
- instead of "sloppycto=N", perhaps "nocto=ro,acctomin=X,acctomax=Y" ?
- only allow mounting with 'noaccesscheck' when sec=sys
- in namei.h, switch LOOKUP_WRITE and LOOKUP_RENAME_TARGET values
  for cosmetic reasons
- ....

Thoughts? Comments? Ridicule? Other solutions?

Mike.
