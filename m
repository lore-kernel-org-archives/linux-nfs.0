From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: NFS client write performance issue ... thoughts?
Date: 08 Jan 2004 12:47:06 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vpdrisjmjpt1.fsf@lemming.engeast.baynetworks.com>
References: <35321.68.42.103.198.1073583166.squirrel@webmail.uio.no>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AeeFa-0002Rd-Ux
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 09:47:18 -0800
Received: from zrtps0kp.nortelnetworks.com ([47.140.192.56])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AeeFa-0006yA-Bg
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 09:47:18 -0800
Received: from zrtps0m6.us.nortel.com (zrtps0m6.us.nortel.com [47.140.192.58])
	by zrtps0kp.nortelnetworks.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i08Hl9i08966
	for <nfs@lists.sourceforge.net>; Thu, 8 Jan 2004 12:47:09 -0500 (EST)
Received: from lemming.engeast.baynetworks.com (mail@lemming.engeast.baynetworks.com [47.17.140.90])
	by zrtps0m6.us.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i08Hl7X03716
	for <nfs@lists.sourceforge.net>; Thu, 8 Jan 2004 12:47:07 -0500 (EST)
Received: from psmith by lemming.engeast.baynetworks.com with local (Exim 3.36 #1 (Debian))
	id 1AeeFO-00066X-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Jan 2004 12:47:06 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <35321.68.42.103.198.1073583166.squirrel@webmail.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

%% <trond.myklebust@fys.uio.no> writes:

  tm> All you are basically showing here is that our write caching sucks
  tm> badly. There's nothing there to pinpoint merging vs not merging
  tm> requests as the culprit.

Good point.  I think that was "intuited" from other info, but I'll have
to check.

  tm> 3 things that will affect those numbers, and cloud the issue:

  tm>   1) Linux 2.4.x has a hard limit of 256 outstanding read+write nfs_page
  tm> struct per mountpoint in order to deal with the fact that the VM does
  tm> not have the necessary support to notify us when we are low on memory
  tm> (This limit has been removed in 2.6.x...).

OK.

  tm>   2) Linux immediately puts the write on the wire once there are more
  tm> than wsize bytes to write out. This explains why bumping wsize results
  tm> in fewer writes.

OK.

  tm>   3) There are accounting errors in Linux 2.4.18 that cause
  tm> retransmitted requests to be added to the total number of transmitted
  tm> ones. That explains why switching to TCP improves matters.

Do you know when those accounting errors were fixed?

ClearCase implements its own virtual filesystem type, and so is heavily
tied to specific kernels (the kernel module is not open source of course
:( ).  We basically can move to any kernel that has been released as
part of an official Red Hat release (say, 2.4.20-8 from RH9 would work),
but no other kernels can be used (the ClearCase kernel module has checks
on the sizes of various kernel structures and won't load if they're not
what it thinks they should be--and since it's a filesystem it cares
deeply about structures that have tended to change a lot.  It won't even
work with vanilla kernel.org kernels of the same version.)

  tm> Note: Try doing this with mmap(), and you will get very different
  tm> numbers, since mmap() can cache the entire database in memory, and only
  tm> flush it out when you msync() (or when memory pressure forces it to do
  tm> so).

OK... except since we don't have the source we can't switch to mmap()
without doing something very hacky like introducing some kind of shim
shared library to remap some read/write calls to mmap().  Ouch.

Also I think that ClearCase _does_ force sync fairly regularly to be
sure the database is consistent.

  tm> One further criticism: there are no READ requests on the Sun
  tm> machine.  That suggests that it had the database entirely in cache
  tm> when you started you test.

Good point.


Thanks Trond!

-- 
-------------------------------------------------------------------------------
 Paul D. Smith <psmith@nortelnetworks.com>   HASMAT--HA Software Mthds & Tools
 "Please remain calm...I may be mad, but I am a professional." --Mad Scientist
-------------------------------------------------------------------------------
   These are my opinions---Nortel Networks takes no responsibility for them.


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
