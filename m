From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: [NFS PATCH] 2.6.0-test10 Invalidate cached inode attributes after rename
Date: 03 Dec 2003 19:42:12 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vpdru14hbehn.fsf@lemming.engeast.baynetworks.com>
References: <3FC501F9.1050306@lehman.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARhZZ-0007ko-4x
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 16:42:25 -0800
Received: from zrtps0kp.nortelnetworks.com ([47.140.192.56])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ARhZY-0005E5-JA
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 16:42:24 -0800
To: "Shantanu Goel" <Shantanu.Goel@lehman.com>
In-Reply-To: <3FC501F9.1050306@lehman.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
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

%% "Shantanu Goel" <Shantanu.Goel@lehman.com> writes:

  sg> 1. Check out a CVS repository into an NFS mounted directory.
  sg> 2. Move files from CVS working directory into another directory in the
  sg> same filesystem.
  sg> 3. Tar up the resultant directory.
  sg> 4. Tar prints lots of "file changed after we read it" messages.

Interesting: I see this exact same message when taring up the contents
of a ClearCase view (in 2.4.20-x)... even though I'm 100% positive that
no one but me is touching those files.  Is this scenario relevant to a
kernel that old as well?

-- 
-------------------------------------------------------------------------------
 Paul D. Smith <psmith@nortelnetworks.com>   HASMAT--HA Software Mthds & Tools
 "Please remain calm...I may be mad, but I am a professional." --Mad Scientist
-------------------------------------------------------------------------------
   These are my opinions---Nortel Networks takes no responsibility for them.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
