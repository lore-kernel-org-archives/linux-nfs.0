From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: NFS client write performance issue ... thoughts?
Date: 06 Jan 2004 13:10:15 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vpdrvfnpkkxk.fsf@lemming.engeast.baynetworks.com>
References: <482A3FA0050D21419C269D13989C6113020AC990@lavender-fe.eng.netapp.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Adves-0001oY-Pz
	for nfs@lists.sourceforge.net; Tue, 06 Jan 2004 10:10:26 -0800
Received: from zrtps0kp.nortelnetworks.com ([47.140.192.56])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Adves-00069x-DJ
	for nfs@lists.sourceforge.net; Tue, 06 Jan 2004 10:10:26 -0800
Received: from zrtps0m6.us.nortel.com (zrtps0m6.us.nortel.com [47.140.192.58])
	by zrtps0kp.nortelnetworks.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i06IAIY10452
	for <nfs@lists.sourceforge.net>; Tue, 6 Jan 2004 13:10:18 -0500 (EST)
Received: from lemming.engeast.baynetworks.com (mail@lemming.engeast.baynetworks.com [47.17.140.90])
	by zrtps0m6.us.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id i06IAGG08911
	for <nfs@lists.sourceforge.net>; Tue, 6 Jan 2004 13:10:16 -0500 (EST)
Received: from psmith by lemming.engeast.baynetworks.com with local (Exim 3.36 #1 (Debian))
	id 1Adveh-0002ae-00
	for <nfs@lists.sourceforge.net>; Tue, 06 Jan 2004 13:10:15 -0500
To: <nfs@lists.sourceforge.net>
In-Reply-To: <482A3FA0050D21419C269D13989C6113020AC990@lavender-fe.eng.netapp.com>
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

%% "Lever, Charles" <Charles.Lever@netapp.com> writes:

  lc> large commercial databases write whole pages, and never
  lc> parts of pages, at once, to their data files.  and they
  lc> write log files by extending them in a single write
  lc> request.

  lc> thus the single-write-request per-page limit is not a
  lc> problem for them.

I'm sure you're correct, but in our environment (ClearCase) the usage
characteristics are very different.

I'm working on getting you some hard numbers but I think we do all agree
that for this particular use case as I've described it, the Linux method
would result in less performance than the Sun method.  I'm not saying
the Sun method is better in all cases, or even in most cases, I'm just
saying that for this particular usage we are seeing a performance
penalty on Linux.


The question is, is there anything to be done about this?  Or is this
too much of a niche situation for the folks on this list to worry much
about?

I took Trond's comments on using mmap() to heart: in retrospect it
surprises me that they don't already use mmap() because I would think
that would give better performance.  But in any case all we can do is
suggest this to IBM/Rational and a major change like that will be a long
time coming, even if they do accept it is a good idea.

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
