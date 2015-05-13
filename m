Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:36697 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934378AbbEMSzn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2015 14:55:43 -0400
Received: by iepk2 with SMTP id k2so39458377iep.3
        for <linux-nfs@vger.kernel.org>; Wed, 13 May 2015 11:55:43 -0700 (PDT)
Message-ID: <1431543341.9235.10.camel@primarydata.com>
Subject: Re: [PATCH] NFS: report more appropriate block size for directories.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: NeilBrown <neilb@suse.de>, Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 13 May 2015 14:55:41 -0400
In-Reply-To: <20150508151459.GA63078@tonberry.usersys.redhat.com>
References: <20150508131040.140bf570@notabene.brown>
	 <20150508151459.GA63078@tonberry.usersys.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2015-05-08 at 11:14 -0400, Scott Mayhew wrote:
> On Fri, 08 May 2015, NeilBrown wrote:
> 
> > 
> > In glibc 2.21 (and several previous), a call to opendir() will
> > result in a 32K (BUFSIZ*4) buffer being allocated and passed to
> > getdents.
> > 
> > However a call to fdopendir() results in an 'fstat' request to
> > determine block size and a matching buffer allocated for subsequent
> > use with getdents.  This will typically be 1M.
> > 
> > The first getdents call on an NFS directory will always use
> > READDIR_PLUS (or NFSv4 equivalent) if available.  Subsequent getdents
> > calls only use this more expensive version if some 'stat' requests are
> > made between the getdents calls.
> > 
> > For this reason it is good to keep at least that first getdents call
> > relatively short.  When fdopendir() and readdir() is used on a large
> > directory, it takes approximately 32 times as long to complete as
> > using "opendir".  Current versions of 'find' use fdopendir() and
> > demonstrate this slowness.
> > 
> > 'stat' on a directory currently returns the 'wsize'.  This number has
> > no meaning on directories.
> > Actual READDIR requests are limited to ->dtsize, which itself is
> > capped at 4 pages, coincidently the same as BUFSIZ*4.
> > So this is a meaningful number to use as the blocksize on directories,
> > and has the effect of making 'find' on large directories go a lot
> > faster.
> 
> Would it make sense to do something similar for regular files too?
> fopen() does a similar buffer allocation unless the application
> overrides the buffer size via setbuffer()/setvbuf().  That can then
> result in fseek() reading a lot of unnecessary data over the wire.
> 
> Prior to commit ba52de1 (inode-diet: Eliminate i_blksize from the inode
> structure), a stat() over nfs would return the page size in st_blksize,
> and for some workloads it does make a difference.  For instance, I have
> a customer running gdb in an diskless environment.  On a stock kernel
> where a stat() over nfs returns the wsize in st_blksize, their job takes
> ~19 minutes... on a test kernel where a stat() over nfs returns the page
> size instead, that same job takes ~13 minutes.  I hadn't sent a patch
> yet because I'm still trying to account for a few extra minutes of
> run time elsewhere...
> 

The client shouldn't be reporting anything different after commit
ba52de1. We should have
  inode->i_blkbits = sb->s_blocksize_bits;

with
  sb->s_blocksize_bits being set as log2(sb->s_blocksize)

Previously, inode->i_blksize was the same as sb_s_blocksize.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


