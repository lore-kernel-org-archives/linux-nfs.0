From: Ian Kent <raven@themaw.net>
Subject: RE: ~800 mountpoint limitation
Date: Wed, 15 Oct 2003 21:01:56 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0310152045310.3025-100000@raven.themaw.net>
References: <6AB920CC10586340BE1674976E0A991D0C6B82@slexch2.sugarland.unocal.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,  <trond.myklebust@fys.uio.no>,
     <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9lCJ-0004Q8-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Oct 2003 05:56:15 -0700
Received: from mail-08.iinet.net.au ([203.59.3.40] helo=mail.iinet.net.au)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A9lCI-00024m-LJ
	for nfs@lists.sourceforge.net; Wed, 15 Oct 2003 05:56:14 -0700
To: "Ogden, Aaron A." <aogden@unocal.com>
In-Reply-To: <6AB920CC10586340BE1674976E0A991D0C6B82@slexch2.sugarland.unocal.com>
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

On Tue, 14 Oct 2003, Ogden, Aaron A. wrote:

> 
> Even so, mounting from 800 separate fileservers would provide much more
> than we have now.  I wonder if there is any real-world site that could
> even approach 800 NFS servers?  (and if so, why???)  With the RPC
> limitations of today I can shatter the limit very easily, all I have to
> do is mount all of my home directories, there are more than 800.

I think Charles is concerned about performance under adverse conditions. 
Certainly a big deal for a busy site like yours.

Even now I can't even saturate a 100m/bit network link (~ 70 - 80% is 
all I can get) on a copy with Linux NFS, so performance is a big deal.

> 
> Re: scalability and performance, I think I'll let Trond and Neil comment
> on that, but Trond's patch for 2.5.73 sounds like a big improvement over
> the current situation.
> 
> I've also noticed that I get RPC errors when I try to mount too many
> things at once, for example if I mount 200+ autofs-managed NFS
> mountpoints via script by cd'ing into them.  If I insert a short pause
> (1/2 second to 1 second) between each mount attempt everything is fine.
> Sounds like some kind of race condition to me...

As I mentioned before it appears that multiple connections are made to the 
portmapper as well. It appears to be using up a bunch of ports. You 
could reduce the amount of time that these ports hang around before 
being released to get'em back quicker. Much like people do on busy web 
servers or perhaps this function is a good candidate for multiplexing as 
well.

I haven't done this on Linux, so I can't help with the how, but it should 
be possible.

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
