Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43238 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409Ab0DVSWO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 14:22:14 -0400
Date: Thu, 22 Apr 2010 14:22:14 -0400
To: Brandon Shandelson <brandon@myshape.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSV4 Replica Support?
Message-ID: <20100422182213.GA8858@fieldses.org>
References: <01c701cae247$e8e50900$baaf1b00$@com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <01c701cae247$e8e50900$baaf1b00$@com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Apr 22, 2010 at 11:16:20AM -0700, Brandon Shandelson wrote:
> I want to use NFSV4 replicas on Ubuntu 9.10 64-bit servers.  It doesnt seem
> to work.  It *looks* like the server kernel module supports it, but the NFS
> client does not.  Is this the case, or should I be able to make replicas
> work on Linux?

What are you actually trying to do?

There's a little support for replication in that the NFSv4 server can be
told to report certain locations as having the same data, but it's not
really supported yet: you need smoething to create the replicas for you
(probably doable with GFS2 as the exported filesystem, or by sharing the
filesystem image if it's read-only).  I don't think the Linux NFSv4
client knows how to use that information yet.

--b.
