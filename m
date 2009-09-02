Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7392 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753053AbZIBShh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Sep 2009 14:37:37 -0400
Message-ID: <4A9EBB6B.4040009@redhat.com>
Date: Wed, 02 Sep 2009 14:37:31 -0400
From: Peter Staubach <staubach@redhat.com>
To: Jason Legate <linux-nfs@proxime.net>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS for millions of files
References: <20090902180841.GF946@proxime.net>
In-Reply-To: <20090902180841.GF946@proxime.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jason Legate wrote:
> Hi, I'm trying to setup a server that we can create millions of files on over
> NFS.  When I run our creation benchmark locally  I can get around 3000 files/
> second in the configuration we're using now, but only around 300/second over
> NFS.  It's mounted as this:
> 
> rw,nosuid,nodev,noatime,nodiratime,hard,bg,nointr,rsize=32768,wsize=32768,tcp,
> nfsvers=3,timeo=600,actimeo=600,nocto
> 
> When I mount the same FS over localhost instead of across the lan, it performs
> about full speed (the 3000/sec).  Anyone have any ideas what I might tweak or
> look at?
> 
> We're going to be testing various XFS/LVM configs to get the best performance,
> but right out the gate, NFS having a 10:1 penalty of performance doesn't bode
> well.
> 

Hi.

Please keep in mind that the NFS stable storage requirements are
probably causing a significant slowdown in activities such as this.
All of the files being created over NFS are being flushed to stable
storage, including modified directory contents and inode information,
before the server responds to the client.  All of those local file
creates are simply manipulating in-memory buffers and are not being
flushed to stable storage until some later time.

There really aren't any good solutions, except perhaps, for
utilizing write caching on the server, and I would only recommend
doing that if you have a good solution, from top to bottom in
the file system and storage stack on the server.  Most aren't.

		ps
