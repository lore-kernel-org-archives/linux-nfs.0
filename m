From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: NFS client write performance issue ... thoughts?
Date: 06 Jan 2004 01:33:29 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vpdrfzetziva.fsf@lemming.engeast.baynetworks.com>
References: <16378.15074.348051.673492@guts.uio.no>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Adkmb-00088C-Fb
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 22:33:41 -0800
Received: from zrtps0kp.nortelnetworks.com ([47.140.192.56])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Adkmb-0003lY-22
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 22:33:41 -0800
Received: from zrtps0m6.us.nortel.com (zrtps0m6.us.nortel.com [47.140.192.58])
	by zrtps0kp.nortelnetworks.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i066XWG02977
	for <nfs@lists.sourceforge.net>; Tue, 6 Jan 2004 01:33:32 -0500 (EST)
Received: from lemming.engeast.baynetworks.com (mail@lemming.engeast.baynetworks.com [47.17.140.90])
	by zrtps0m6.us.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i066XU004148
	for <nfs@lists.sourceforge.net>; Tue, 6 Jan 2004 01:33:30 -0500 (EST)
Received: from psmith by lemming.engeast.baynetworks.com with local (Exim 3.36 #1 (Debian))
	id 1AdkmQ-00043s-00
	for <nfs@lists.sourceforge.net>; Tue, 06 Jan 2004 01:33:30 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <16378.15074.348051.673492@guts.uio.no>
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

%% Trond Myklebust <trond.myklebust@fys.uio.no> writes:

  tm> P=E5 m=E5 , 05/01/2004 klokka 17:11, skreiv Paul Smith:
  >> Hi all; we've been doing some examination of NFS client performance, a=
nd
  >> have seen this apparently sub-optimal behavior: anyone here have any
  >> comments on this observation or thoughts about it?

  tm> Does your observation include numbers, or is it just conjecture?

Note I'm only forwarding comments I've received from another party,
who's actually doing the investigation.

The application in question is not GDBM but rather ClearCase; I guess
there's some concern that the performance of ClearCase over NFS from a
Linux client seems to be noticeably less than from a Solaris client.
ClearCase uses a (heavily) customized version of the Raima database to
store its internal information.

I'll see if I can get any numbers.

  tm> The Solaris approach is only a win in the particular case where
  tm> you are doing several non-contiguous writes into the same page
  tm> (and without any byte-range locking).  Note that like Linux, two
  tm> processes that do not share the same RPC credentials still cannot
  tm> merge their writes since you cannot rely on them having the same
  tm> file write permissions.

In this particular case that's fine since the ClearCase database is only
ever modified by one process on one system.

  tm> Looking at your particular example of GDBM, you should recall that
  tm> Solaris is forced to revert to uncached synchronous reads and writes
  tm> when doing byte range locking precisely because their page cache
  tm> writes back entire pages (the ugly alternative would be to demand that
  tm> byte range locks must be page-aligned).
  tm> OTOH Linux can continue to do cached asynchronous reads and writes
  tm> right up until the user forces an fsync()+cache invalidation by
  tm> changing the locking range because our page cache writes are not
  tm> required to be page aligned.

Of course I don't have the source and I haven't sniffed the packets
personally so I don't know exactly what goes on, but it's quite possible
that the ClearCase implementation doesn't attempt to do any byte-range
locking at all, since they pretty much know that there is only one
process reading and writing the DB.

The reason for using NFS involves maintenance, backup, reliability,
etc. etc. (the NFS server is actually an EMC or NetApp NAS solution),
not necessarily file sharing, at least insofar as the DB itself is
concerned.



Thanks for the reply, Trond; I'll see if I can get more concrete
details and let you know.

--=20
---------------------------------------------------------------------------=
----
 Paul D. Smith <psmith@nortelnetworks.com>   HASMAT--HA Software Mthds & To=
ols
 "Please remain calm...I may be mad, but I am a professional." --Mad Scient=
ist
---------------------------------------------------------------------------=
----
   These are my opinions---Nortel Networks takes no responsibility for them.


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
