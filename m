From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: 2.6.34rc4 NFS writeback regression (bisected): client often
 fails to delete things it just created
Date: Sun, 18 Apr 2010 15:21:24 -0400
Message-ID: <1271618484.8049.1.camel@localhost.localdomain>
References: <87tyr9dfvv.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Nix <nix@esperi.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37474 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab0DRTVl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Apr 2010 15:21:41 -0400
In-Reply-To: <87tyr9dfvv.fsf-AdTWujXS48Mg67Zj9sPl2A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2010-04-17 at 20:43 +0100, Nix wrote: 
> [Trond Cc:ed as this seems to be a bug in one of your
>  writeback-for-2.6.34 commits.]
> 
> In 2.6.34rcX (tip of tree) I've started seeing this sort of thing when
> building over NFS (v3):
> 
> [...]
> -- Found LibXslt: /usr/lib64/libxslt.so
> --   found libxml-2.0, version 2.7.6
> -- Found LibXml2: /usr/lib64/libxml2.so
> -- Found shared-mime-info version: 0.71
> -- Looking for __progname
> CMake Error: Remove failed on file: /usr/src/kde/x86_64-mutilate/build/CMakeFiles/CMakeTmp/CMakeFiles/cmTryCompileExec.dir/.nfs000000000031fc510000082f: System Error: Device or resource busy
> [... eventually, cmake fails because of this error.]
> 
> The silly-renamed files are invariably no longer in use (they tend to be
> GCC output, ELF executables run as part of testsuites) but haven't been
> removed, and they -EBUSY when removal is attempted.
> 
> A complete strace log of running cmake against current HEAD (with lots
> of these errors) is at
> <http://www.esperi.org.uk/~nix/temporary/strace-kdelibs-nfs-EBUSY.log.lzma>.
> I can do a packet capture too if you like.
> 
> I also see it after doing 'make install's followed by an 'rm -rf' of the
> build tree: the rm -rf fails because half the files are 'in use' (they
> aren't). Repeating the rm -rf a few seconds later works. fuser, even as
> root, shows no processes holding these files open.
> 
> This bisects down to
> 
> commit acdc53b2146c7ee67feb1f02f7bc3020126514b8
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Fri Feb 19 17:03:26 2010 -0800
> 
>     NFS: Replace __nfs_write_mapping with sync_inode()
>     
>     Now that we have correct COMMIT semantics in writeback_single_inode, we can
>     reduce and simplify nfs_wb_all(). Also replace nfs_wb_nocommit() with a
>     call to filemap_write_and_wait(), which doesn't need to hold the
>     inode->i_mutex.
>     
>     With that done, we can eliminate nfs_write_mapping() altogether.
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> I suspect that unlink()ing a not otherwise open file for which writeback
> is still underway is causing the files to be sillyrenamed because
> writeback is holding them open. If writeback is the only user, they
> should surely not be held open: nobody cares what their contents are,
> and a lot of code depends on rm -r of directories containing recently-
> written-but-still-closed files succeeding.

Did you test with commit b80c3cb628f0ebc241b02e38dd028969fb8026a2 (NFS:
Ensure that writeback_single_inode() calls write_inode() when syncing)?
That fixed the above problem on my setup.

Cheers
  Trond
