From: Daniel Ellard <ellard@eecs.harvard.edu>
Subject: NFS trace wish list?
Date: Thu, 10 Apr 2003 18:59:11 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.BSF.4.51.0304101839050.72189@bowser.eecs.harvard.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bowser.eecs.harvard.edu
	([140.247.60.24] helo=mail.eecs.harvard.edu ident=postfix)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 193l0j-0002ds-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Apr 2003 15:59:13 -0700
Received: from localhost (localhost [127.0.0.1])
	by mail.eecs.harvard.edu (Postfix) with ESMTP id CE67954C4B6
	for <nfs@lists.sourceforge.net>; Thu, 10 Apr 2003 18:59:11 -0400 (EDT)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Hello--

	As part of my research in file systems, I have written an NFS
tracing program (based largely on tcpdump, but with the ability to
capture more information) and a bunch of PERL scripts for scanning
through the traces and finding useful info.  It has been very useful
to my work, and from my conversations with other people, I think it
might be a useful tool to other people.  I'd like to document and
bundle up the tools I have and/or add some new tools that make them
useful in a general context.  However, I don't really know what
functionality other people are looking for.

Here's where you can help.  I'm trying to put together a wish list of
NFS analysis tools -- what tools would you like that you haven't got?

Some ideas people have already suggested:

- Load pattern analysis.

	If your network is like ours, then 3am is not a good time to
	do backups.  Everyone thinks the system is idle in the middle
	of the night, so they all schedule their big jobs to run in
	the small hours of the morning...

- Hot file/directory spotting.

	Watch for files that get read a lot by lots of clients, but
	not written.  (maybe they can be replicated, possibly closer
	to the clients)

- Hot client spotting.

	For servers with multiple interfaces on different subnets,
	figure out which clients are soaking up all the bandwidth and
	spread them out between the subnets to balance the load.

These are pretty mundane.  Tell me what you really want...

Thanks,
	-Dan




-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
