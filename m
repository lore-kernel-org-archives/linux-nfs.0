Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53399 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184Ab1CWV2G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 17:28:06 -0400
Date: Thu, 24 Mar 2011 08:27:54 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: peter.staubach@emc.com, bfields@fieldses.org, bjschuma@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] NFS: Detect loops in a readdir due to bad cookies
Message-ID: <20110324082754.76f199a6@notabene.brown>
In-Reply-To: <1300906115.11677.58.camel@lade.trondhjem.org>
References: <4D8A3060.807@netapp.com>
	<20110323182524.GB25284@fieldses.org>
	<1300905243.11677.53.camel@lade.trondhjem.org>
	<5E6794FC7B8FCA41A704019BE3C70E8B0693F05F@MX31A.corp.emc.com>
	<1300906115.11677.58.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 23 Mar 2011 14:48:35 -0400 Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:

> On Wed, 2011-03-23 at 14:42 -0400, peter.staubach@emc.com wrote:
> > Although I think that it is a good thing to protect the client against broken servers, it does seem like the right solution is to get the server fixed...
> 
> Don't get me wrong: I fully agree with that!

Ack.

As I understand it, ext4 (and ext3) use the hash of the basename as the
cookie.  This hash has a per-directory random seed which is hidden so it is
not possible to deliberately create files with the same hash, but thanks to
the birthday paradox it isn't too hard to get collisions in a suitably large
directory.

For 'readdir' ext4 keeps extra state in the 'struct file' so that it knows
where it was up to in a list of names with the same hash and so won't return
duplicates.  However if you telldir/seekdir you will restart at the start of
the sequence (I think).

Assuming that the fs always delivers names-with-the-same-cookie in a
contiguous set (which seems likely), NFSD could mitigate this problem by
treating them as a unit.
i.e. to a given READDIR request, it either returns all names with a
particular cookie, or none of them.
This could only work if the set of names with the one cookie fits inside a
single reply, but that should be likely unless the rsize is tiny.

nfsd should also, after lseeking to the given address, skip over any
subsequent entries that have the same address.
This would ensure no looping happened, and the first step would make it
unlikely that names were missed.

It would be nice if filesystems would get this right, but I think it is
reasonable for NFSD to take steps like this to guard against unfortunate
filesystem design.

NeilBrown
