Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43988 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347Ab1FVXTr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 19:19:47 -0400
Date: Thu, 23 Jun 2011 00:19:46 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [heads-up] mknod() broken on nfs4
Message-ID: <20110622231946.GH11521@ZenIV.linux.org.uk>
References: <20110621235900.GB11521@ZenIV.linux.org.uk>
 <20110622002359.GC11521@ZenIV.linux.org.uk>
 <1308783620.25875.30.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1308783620.25875.30.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jun 22, 2011 at 07:00:20PM -0400, Trond Myklebust wrote:
> > Folks, how is that code supposed to work?  lookup_instantiate_filp() should
> > *not* be called by vfs_create() triggered by mknod().  And I don't see any
> > codepath in nfs_open_create() that would not step into that.  ctx == NULL
> > is the only thing that would skip it and it definitely isn't survivable
> > by nfs4_proc_create().  Moreover, we need the rpc_cred to come from somewhere
> > and nfs4_proc_create() needs to get it from us.
> 
> I agree that we should error out gracefully instead of blowing up, but I
> fail to see why we want to support mknod for a regular file: it's not a
> posix interface, nor is it substantially different from open(O_CREAT|
> O_EXCL|O_NOFOLLOW). What is it's purpose?

It always worked that way, all the way back to Unix v6 (and I'm fairly sure
to earlier than that; don't have v5 kernel source, unfortunately).  Worked
that way in Linux since 0.02/0.03/0.10, when Linus first added mknod(2)
(presumably 0.01 had been tested with /dev populated by Minix ;-)

As for POSIX, what it says is
     The only portable use of mknod() is to create a FIFO-special file.         
     If mode is not S_IFIFO or dev is not 0, the behaviour of mknod() is        
     unspecified.                                                               
and we support it for all non-directories.  Always had...

	Note that the right thing to do is to issue CLOSE and _not_ call
lookup_instantiate_filp() if we are called from sys_mknodat().  We don't
want to leak stateid...
