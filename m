From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: [NFS PATCH] 2.6.0-test10 Invalidate cached inode attributes after rename
Date: 04 Dec 2003 12:20:57 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vpdrn0a8v6rq.fsf@lemming.engeast.baynetworks.com>
References: <482A3FA0050D21419C269D13989C6113020AC815@lavender-fe.eng.netapp.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shantanu Goel <Shantanu.Goel@lehman.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARxA6-0002hx-Sl
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 09:21:10 -0800
Received: from zrtps0kp.nortelnetworks.com ([47.140.192.56])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ARxA6-00032s-0n
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 09:21:10 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113020AC815@lavender-fe.eng.netapp.com>
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

  lc> i'll state this more carefully -- the problem is exposed after
  lc> trond's readdirplus patch is applied to 2.4.2x.

I'm using Red Hat's 2.4.20-8 and 2.4.18-19.8.0 kernels.  They probably
applied this patch as well.

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
