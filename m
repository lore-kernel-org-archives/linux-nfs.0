Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40908 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911Ab3HQALz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Aug 2013 20:11:55 -0400
Date: Fri, 16 Aug 2013 17:12:18 -0400
To: Martin Hicks <mort@bork.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: server mountpoint busy after unexporting nfs4 share
Message-ID: <20130816211217.GB21539@fieldses.org>
References: <CAJUS3XmebzQHnQNwEYECUjYyK+nj2cVpKz_-4gmPacEWzmxEZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJUS3XmebzQHnQNwEYECUjYyK+nj2cVpKz_-4gmPacEWzmxEZQ@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 15, 2013 at 12:04:33PM -0400, Martin Hicks wrote:
> I'm wondering if I'm missing something or if this is a bug.
> 
> A NFS4 export has active clients.  The mount is removed from
> /etc/exports and 'exportfs -r' is run.  Clients immediately start
> getting 'Stale file handle' errors, but the mountpoint is still busy
> and cannot be unmounted.  Killing off nfsd solves the problem, but is
> undesirable for obvious reasons.
> 
> On debian linux, kernel version 3.10-2-amd64,  with nfs-utils 1.2.8.

Yeah, the clients may hold opens or locks on the filesystem and those
don't get removed on exports -r.

For now shutting down the server is the only solution.

We could possibly fix that, or provide some other way to do whatever it
is you're trying to do, but it's likely not a small change.

Nevertheless, for future reference it would be interesting to know what
exactly you're trying to do.

--b.
