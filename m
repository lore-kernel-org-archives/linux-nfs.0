From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: (autofs) Re: Direct mounts on Linux
Date: 21 Jan 2003 01:05:30 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <p5r8b7yr4l.fsf@lemming.engeast.baynetworks.com>
References: <15916.14776.460148.770017@lemming.engeast.baynetworks.com>
	<20030120214134.GE1042@questra.com>
	<p5vg0jz08z.fsf@lemming.engeast.baynetworks.com>
	<20030121030851.GG10369@questra.com>
	<p5wukzyx8m.fsf@lemming.engeast.baynetworks.com>
	<20030121040318.GI10369@questra.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from zrtps0kn.nortelnetworks.com ([47.140.192.55])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18arXa-00011p-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Jan 2003 22:05:43 -0800
To: Scott Mcdermott <smcdermott@questra.com>
In-Reply-To: <20030121040318.GI10369@questra.com>
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

%% Scott Mcdermott <smcdermott@questra.com> writes:

  sm> mostly nowadays, `pwd' is a shell builtin that doesn't use the
  sm> algorithm you refer to, if I understand right (like /bin/pwd has
  sm> to use, eg keep going ..) instead keeping track internally.

Well, sure, but there's still getcwd() ... :)

-- 
-------------------------------------------------------------------------------
 Paul D. Smith <psmith@nortelnetworks.com>   HASMAT--HA Software Mthds & Tools
 "Please remain calm...I may be mad, but I am a professional." --Mad Scientist
-------------------------------------------------------------------------------
   These are my opinions---Nortel Networks takes no responsibility for them.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
