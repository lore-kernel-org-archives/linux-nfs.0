Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:39884 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755Ab1JTSIU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 14:08:20 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RGx2R-00080a-9B
	for linux-nfs@vger.kernel.org; Thu, 20 Oct 2011 20:08:19 +0200
Received: from ebox.rath.org ([173.255.235.238])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 20 Oct 2011 20:08:19 +0200
Received: from Nikolaus by ebox.rath.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 20 Oct 2011 20:08:19 +0200
To: linux-nfs@vger.kernel.org
From: Nikolaus Rath <Nikolaus@rath.org>
Subject: Re: Does NFS4 need st_gen?
Date: Thu, 20 Oct 2011 13:21:31 -0400
Message-ID: <877h3za89w.fsf@inspiron.ap.columbia.edu>
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>
	<20111019171551.GA32028@fieldses.org>
	<87d3dsdcf4.fsf@inspiron.ap.columbia.edu>
	<20111020120207.GL5444@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> writes:
> On Wed, Oct 19, 2011 at 03:11:27PM -0400, Nikolaus Rath wrote:
>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>> > On Wed, Oct 19, 2011 at 10:17:43AM -0400, Nikolaus Rath wrote:
>> >> Does NFS4 still depend on inode generation numbers? I understand that
>> >> earlier NFS versions used file handles based on inode and generation
>> >> number, but it seems to me that this shouldn't be required anymore with
>> >> the (stateful) NFS4.
>> >
>> > Yes, it's true that NFSv4 has open and close operations, but filehandles
>> > are still used a great deal outside of that, and clients are still
>> > allowed to assume that the same filehandle always refers to the same
>> > object.
>> >
>> > http://www.ietf.org/rfc/rfc3530.txt, section 4.2.1:
>> >
>> > 	"If two filehandles from the same server are equal, they MUST
>> > 	refer to the same file."
>> 
>> Duh - that's a disappointment. Thanks for the pointer!
>
> Just curious--why do you care?

I'm working on a FUSE file system that stores file system metadata in an
SQL database (http://code.google.com/p/s3ql/). Not having to keep track
of inode generation numbers would keep the code much simpler, because I
want to delete inode-rows from the SQL table when the last reference to
the inode is deleted (so I can't keep track of the generation no).

Now I'll either have to make inodes unique (and run into trouble after
2^32 inodes have been used), or keep with the current scheme of
randomizing new inodes (which keeps the probability of problems low
enough but is ugly).

Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C

