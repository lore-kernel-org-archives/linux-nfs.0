Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35699 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130Ab1FWFht (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 01:37:49 -0400
Date: Thu, 23 Jun 2011 06:37:45 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [heads-up] mknod() broken on nfs4
Message-ID: <20110623053745.GJ11521@ZenIV.linux.org.uk>
References: <20110621235900.GB11521@ZenIV.linux.org.uk>
 <20110622002359.GC11521@ZenIV.linux.org.uk>
 <1308783620.25875.30.camel@lade.trondhjem.org>
 <20110622231946.GH11521@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110622231946.GH11521@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 23, 2011 at 12:19:46AM +0100, Al Viro wrote:
> It always worked that way, all the way back to Unix v6 (and I'm fairly sure
> to earlier than that; don't have v5 kernel source, unfortunately).  Worked
> that way in Linux since 0.02/0.03/0.10, when Linus first added mknod(2)
> (presumably 0.01 had been tested with /dev populated by Minix ;-)
> 
> As for POSIX, what it says is
>      The only portable use of mknod() is to create a FIFO-special file.         
>      If mode is not S_IFIFO or dev is not 0, the behaviour of mknod() is        
>      unspecified.                                                               
> and we support it for all non-directories.  Always had...
> 
> 	Note that the right thing to do is to issue CLOSE and _not_ call
> lookup_instantiate_filp() if we are called from sys_mknodat().  We don't
> want to leak stateid...

OK...  See #untested in vfs-2.6.git; the last 5 commits there.  The actual
fixes are in the last one; to get rid of the dependency on the previous
we'd just need to pass open_flags as additional argument to
nameidata_to_nfs_open_context() (like untested@{1}, but without removal
of nameidata argument - that part depends on earlier commits and is, IMO,
a good idea anyway).

It seems to work here.  Testing and comments would be welcome...
