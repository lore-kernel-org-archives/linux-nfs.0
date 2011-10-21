Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:56786 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754529Ab1JUOIZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Oct 2011 10:08:25 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RHFlm-00054D-FR
	for linux-nfs@vger.kernel.org; Fri, 21 Oct 2011 16:08:22 +0200
Received: from ebox.rath.org ([173.255.235.238])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 21 Oct 2011 16:08:22 +0200
Received: from Nikolaus by ebox.rath.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 21 Oct 2011 16:08:22 +0200
To: linux-nfs@vger.kernel.org
From: Nikolaus Rath <Nikolaus@rath.org>
Subject: Re: Does NFS4 need st_gen?
Date: Fri, 21 Oct 2011 09:54:01 -0400
Message-ID: <87vcrisb5y.fsf@inspiron.ap.columbia.edu>
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>
	<20111019171551.GA32028@fieldses.org>
	<87d3dsdcf4.fsf@inspiron.ap.columbia.edu>
	<20111020120207.GL5444@fieldses.org>
	<877h3za89w.fsf@inspiron.ap.columbia.edu>
	<20111020195731.GC9987@fieldses.org>
	<871uu79z7m.fsf@inspiron.ap.columbia.edu>
	<1319155647.2768.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> writes:
> On Thu, 2011-10-20 at 16:37 -0400, Nikolaus Rath wrote: 
>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>> > On Thu, Oct 20, 2011 at 01:21:31PM -0400, Nikolaus Rath wrote:
>> >> I'm working on a FUSE file system that stores file system metadata in an
>> >> SQL database (http://code.google.com/p/s3ql/). Not having to keep track
>> >> of inode generation numbers would keep the code much simpler, because I
>> >> want to delete inode-rows from the SQL table when the last reference to
>> >> the inode is deleted (so I can't keep track of the generation no).
>> >
>> > You can use current time, or a counter, or something, as the generation
>> > number.
>> 
>> With current time I'm screwed if the system clock doesn't have
>> sufficiently fine granularity. With a counter, I either have to remember
>> counter values per-inode even after the inode is deleted, or the global
>> counter will overflow at some point (in which case I may just as well
>> require unique inodes in the first place).
>
> The filehandle is between 32 (NFSv2) and 128(NFSv4) bytes long. How long
> do you expect it to take you to create+destroy between 2^256 and 2^1024
> inodes? I'm guessing that we'll all be long dead and the universe will
> have undergone heat death before that happens...

Please stop assuming that I'm stupid or haven't thought about the
problem at all. The bottleneck is not the length of the NFS file handle,
but the length of the inode and generation number (both of which are
restricted to 32bit by FUSE) together with the requirement that not only
both of them together need to be unique forever, but the inode also
needs to be unique at any given instant (so they cannot be trivially
combined to form a 64bit value).

Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C

