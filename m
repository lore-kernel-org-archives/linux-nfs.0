From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: NFS client write performance issue ... thoughts?
Date: Mon, 5 Jan 2004 17:11:11 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16377.57599.284453.729190@lemming.engeast.baynetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AdcwV-0002X1-3U
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 14:11:23 -0800
Received: from zrtps0kp.nortelnetworks.com ([47.140.192.56])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AdcwU-0004L7-Jk
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 14:11:22 -0800
Received: from zrtps0m6.us.nortel.com (zrtps0m6.us.nortel.com [47.140.192.58])
	by zrtps0kp.nortelnetworks.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i05MBDM18379
	for <nfs@lists.sourceforge.net>; Mon, 5 Jan 2004 17:11:13 -0500 (EST)
Received: from lemming.engeast.baynetworks.com (mail@lemming.engeast.baynetworks.com [47.17.140.90])
	by zrtps0m6.us.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i05MBBo02006
	for <nfs@lists.sourceforge.net>; Mon, 5 Jan 2004 17:11:11 -0500 (EST)
Received: from psmith by lemming.engeast.baynetworks.com with local (Exim 3.36 #1 (Debian))
	id 1AdcwJ-0008Ki-00
	for <nfs@lists.sourceforge.net>; Mon, 05 Jan 2004 17:11:11 -0500
To: nfs@lists.sourceforge.net
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

Hi all; we've been doing some examination of NFS client performance, and
have seen this apparently sub-optimal behavior: anyone here have any
comments on this observation or thoughts about it?

Thanks!

> I was looking at the code (which doesn't appear to be fixed in 2.6),
> and here's what I think it's doing.
> 
> The Linux NFS client code is capable of only remembering a write to a
> single contiguous chunk in each 4KB page of a file.  If a second
> non-contiguous write occurs to the page, the first write has to be
> flushed to the server.  So if the view server is seeking around in a
> file writing a few bytes here and a few there, whenever it does a
> write to a page that has already been written, the first write has to
> be flushed to the server.  The code that does most of this is in
> fs/nfs/write.c, function nfs_update_request().  That's the routine
> that, given a new write request, searches for an existing one that is
> contiguous with the new one.  If it finds a contiguous request, the
> new one is coalesced with it and no NFS activitity is required.  If
> instead it finds a pending write to the same page, it returns EBUSY to
> its caller, which tells the caller (nfs_updatepage()) to synchronously
> write the existing request to the server.
> 
> The Solaris NFS client (and probably most other NFS client
> implementations) doesn't work this way.  Whenever a small write is
> made to a block of a file, the block is read from the server, and then
> the write is applied to the cached block.  If the block is already in
> cache, the write is applied to block without any NFS transactions
> being required.  When the file is closed or fsync()ed, the entire
> block is written to the server.  So the client code doesn't need to
> record each individual small write to a block, it just modifies the
> cached block as necessary.
> 
> I don't know why the Linux NFS client doesn't work this way, but I
> think it wouldn't be difficult to make it work that way.  In some
> scenarios, this might be a performance hit (because an entire block of
> the file has to be read from the server just to write a few bytes to
> it), but I think that in most cases, doing it the Solaris way would be
> a performance win.  I'd guess that if any sort of database, such as a
> GDBM database, is accessed over NFS, the Linux method would result in
> much poorer performance than the Solaris method.


-- 
-------------------------------------------------------------------------------
 Paul D. Smith <psmith@nortelnetworks.com>   HASMAT: HA Software Mthds & Tools
 "Please remain calm...I may be mad, but I am a professional." --Mad Scientist
-------------------------------------------------------------------------------
   These are my opinions---Nortel Networks takes no responsibility for them.


-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
