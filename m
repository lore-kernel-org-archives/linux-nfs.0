From: Ian Kent <raven@themaw.net>
Subject: Re: RE: [autofs] multiple servers per automount
Date: Tue, 14 Oct 2003 21:37:37 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0310142131090.3044-100000@raven.themaw.net>
References: <10324.1066115107@ichips.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Ogden, Aaron A." <aogden@unocal.com>,
    autofs mailing list <autofs@linux.kernel.org>,
     <nfs@lists.sourceforge.net>, Mike Waychison <Michael.Waychison@Sun.COM>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9PFn-0002Gq-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 06:30:23 -0700
Received: from mail-05.iinet.net.au ([203.59.3.37] helo=mail.iinet.net.au)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A9PFm-00011O-MQ
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 06:30:22 -0700
To: Joseph V Moss <jmoss@ichips.intel.com>
In-Reply-To: <10324.1066115107@ichips.intel.com>
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

On Tue, 14 Oct 2003, Joseph V Moss wrote:

> The limit is 800 as others have stated.  Although, it can be less than that
> if something else is already using up some of the reserved UDP ports.
> 
> I wrote a patch long ago against a 2.2.x kernel to enable it to use
> multiple majors for NFS mounts (like the patches now common in several
> distros).  I then ran into the 800 limit in the RPC layer.  After changing
> the RPC layer to count up from 0, instead of down from 800, with no real
> upper limit, I was able to mount more than 2000 NFS filesystems simultaneously.
> I'm sure I could have done many thousand if I had had that many filesystems
> around to mount.  Obviously, after 1024, it wasn't using reserved ports
> anymore, but it didn't seem to matter.
> 
> Unfortunately, while the changes to NFS were easy to port to the 2.4 kernel,
> the RPC layer is different enough between 2.2 and 2.4 that it didn't work
> right off.  Bumping it up to somewhere around 1024 should work, but using
> non-reserved ports didn't seem to work when I made a simple attempt.
> 
> Of course, the real fix for the NFS layer is the expansion of the minor
> numbers that's already occurred in 2.6 and the RPC layer problems should
> be fixed by multiplexing multiple mounts on the same port.
> 
> 

I don't see that expansion in 2.6 (test6). It looks to me like the 
allocation is done in set_anon_super (in fs/super.c) and that looks like 
it is restricted to 256. Please correct this for me. I can't see how there 
is any change to the number of unnmaed devices.

-- 

   ,-._|\    Ian Kent
  /      \   Perth, Western Australia
  *_.--._/   E-mail: raven@themaw.net
        v    Web: http://themaw.net/



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
