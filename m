From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: [OT] (autofs) Re: Direct mounts on Linux
Date: 21 Jan 2003 02:59:20 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <p58yxfyluv.fsf@lemming.engeast.baynetworks.com>
References: <15916.14776.460148.770017@lemming.engeast.baynetworks.com>
	<20030120214134.GE1042@questra.com>
	<p5vg0jz08z.fsf@lemming.engeast.baynetworks.com>
	<20030121030851.GG10369@questra.com>
	<p5wukzyx8m.fsf@lemming.engeast.baynetworks.com>
	<20030121040318.GI10369@questra.com>
	<p5r8b7yr4l.fsf@lemming.engeast.baynetworks.com>
	<20030121064851.GK10369@questra.com>
	<p5iswjyocn.fsf@lemming.engeast.baynetworks.com>
	<20030121072351.GC12523@questra.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Scott Mcdermott <smcdermott@questra.com>
In-Reply-To: <20030121072351.GC12523@questra.com>
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

  sm> Paul Smith on Tue 21/01 02:05 -0500:

  >> No, I mean getcwd(3), the C runtime library function... if my program
  >> invokes this then it doesn't matter what the shell does.

  sm> Not if you chdir("/") like a good little daemon

Well, not everything that I run is a daemon... and yet it still may need
to run getcwd() :).

  sm> yeah I know, I get your point :) If that is the only argument
  sm> against direct mounts though, I really don't understand statements
  sm> like "[Autofs.  Will.  Never.  Support.  Direct.  Maps.  Period.
  sm> Full Stop.]"

  sm> (see autofs mailing list archives from H. Peter Anvin)

I dunno either.  Maybe this has more to do with the unclean hacks
required to implement direct mounts in the kernel than the issues the
user has with direct mounts from the outside.

Anyway, this is probably pretty OT for this list, and it's time for me
to go to bed!

Thanks all...

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
