From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: Direct mounts on Linux
Date: 20 Jan 2003 21:48:28 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <p5vg0jz08z.fsf@lemming.engeast.baynetworks.com>
References: <15916.14776.460148.770017@lemming.engeast.baynetworks.com>
	<20030120214134.GE1042@questra.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from zrtps0kn.nortelnetworks.com ([47.140.192.55])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18aoSv-0007la-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Jan 2003 18:48:41 -0800
To: Scott Mcdermott <smcdermott@questra.com>
In-Reply-To: <20030120214134.GE1042@questra.com>
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

  sm> Paul Smith on Mon 20/01 13:02 -0500:

  >> I saw a note that direct mounts are not supported on Linux; is this
  >> true even for autofs?  Or only for user-space stuff like am-utils?

  sm> It is true only for autofs.  Of course "mount server:/path
  sm> /mount/point" will always work :)

Well, I kind of meant automounting, so autofs and am-utils :).

I know that am-utils doesn't support it, and a note in their docs seems
to imply that the Linux kernel itself doesn't support it... so I was
curious if autofs supported it.

For example, am-utils on FreeBSD does support direct mounts IIRC.

  sm> Word has it that the am-utils now speaks autofs to the kernel, and
  sm> does support direct mounts (among other things), so one can have
  sm> the best of both worlds (speed and features)

Interesting!

  sm> Now we can finally get along in a Sun environment without hacks.

Well... except for direct mounts.  We can all agree that they are evil
and they suck, but the fact remains there are a lot of them out there
and they are often hard to get rid of...

  sm> autofs has its own mailing list btw

OK, thanks.

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
