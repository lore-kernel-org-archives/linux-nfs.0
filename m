From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: (autofs) Re: Direct mounts on Linux
Date: 20 Jan 2003 22:53:29 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <p5wukzyx8m.fsf@lemming.engeast.baynetworks.com>
References: <15916.14776.460148.770017@lemming.engeast.baynetworks.com>
	<20030120214134.GE1042@questra.com>
	<p5vg0jz08z.fsf@lemming.engeast.baynetworks.com>
	<20030121030851.GG10369@questra.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from zrtps0kn.nortelnetworks.com ([47.140.192.55])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18apTo-0007Mo-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Jan 2003 19:53:41 -0800
To: Scott Mcdermott <smcdermott@questra.com>
In-Reply-To: <20030121030851.GG10369@questra.com>
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

  sm> hmm direct mounts? well according to the docs:

  sm>   [...]

I saw that, but then there was another note saying that as of kernel
2.4.10 they had removed the "direct mount hack" and now direct mounts
were totally unsupported.  I'll have to go back and find that again.

  >> Well... except for direct mounts.  We can all agree that they are
  >> evil and they suck, but the fact remains there are a lot of them
  >> out there and they are often hard to get rid of...

  sm> I don't agree that they are evil or that they suck.  Some mounts
  sm> are static and won't change, and just a simple mount will suffice.
  sm> What's wrong with using a direct mount in this case (maybe /home/
  sm> or /var/spool/mail/)? Is there a real argument against this
  sm> besides "the performance sucks when the directory gets large"
  sm> (which is an admin decision I think).  I don't really know, we
  sm> don't have large enough directories that it becomes a problem.
  sm> One other good thing about direct mounts is that you can
  sm> immediately `ls' the directory and see all the possible entries,
  sm> but this could be implemented in other ways.

Well, if you mount directly in / it can be a big problem, since commands
like pwd etc. often use an algorithm that can hang if one of your direct
mounts in / is unavailable.

I suppose if you mount below / it's not so bad, but my understanding is
that every direct mount uses up resources even if it's not mounted, so
as you say if you have a lot of them it's a problem (and we do have a
lot, unfortunately).

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
