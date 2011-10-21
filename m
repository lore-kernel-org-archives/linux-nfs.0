Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32786 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039Ab1JUAH2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2011 20:07:28 -0400
Subject: Re: Does NFS4 need st_gen?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nikolaus Rath <Nikolaus@rath.org>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 20 Oct 2011 19:07:27 -0500
In-Reply-To: <871uu79z7m.fsf@inspiron.ap.columbia.edu>
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>
	 <20111019171551.GA32028@fieldses.org>
	 <87d3dsdcf4.fsf@inspiron.ap.columbia.edu>
	 <20111020120207.GL5444@fieldses.org>
	 <877h3za89w.fsf@inspiron.ap.columbia.edu>
	 <20111020195731.GC9987@fieldses.org>
	 <871uu79z7m.fsf@inspiron.ap.columbia.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1319155647.2768.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-10-20 at 16:37 -0400, Nikolaus Rath wrote: 
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> > On Thu, Oct 20, 2011 at 01:21:31PM -0400, Nikolaus Rath wrote:
> >> I'm working on a FUSE file system that stores file system metadata in an
> >> SQL database (http://code.google.com/p/s3ql/). Not having to keep track
> >> of inode generation numbers would keep the code much simpler, because I
> >> want to delete inode-rows from the SQL table when the last reference to
> >> the inode is deleted (so I can't keep track of the generation no).
> >
> > You can use current time, or a counter, or something, as the generation
> > number.
> 
> With current time I'm screwed if the system clock doesn't have
> sufficiently fine granularity. With a counter, I either have to remember
> counter values per-inode even after the inode is deleted, or the global
> counter will overflow at some point (in which case I may just as well
> require unique inodes in the first place).

The filehandle is between 32 (NFSv2) and 128(NFSv4) bytes long. How long
do you expect it to take you to create+destroy between 2^256 and 2^1024
inodes? I'm guessing that we'll all be long dead and the universe will
have undergone heat death before that happens...

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

