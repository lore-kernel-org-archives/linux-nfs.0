From: canon@pookie.nersc.gov
Subject: Re: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Thu, 05 Dec 2002 09:28:01 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200212051728.gB5HS1jH005843@pookie.nersc.gov>
References: <CFEAJJEGMGECBCJFLGDBMEHJCJAA.hammer@clarkisland.com>
Cc: "Jake Hammer" <hammer@clarkisland.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pookie.nersc.gov ([128.55.16.113])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18JzY2-0007ND-00
	for <nfs@lists.sourceforge.net>; Thu, 05 Dec 2002 09:12:26 -0800
To: "NFS" <nfs@lists.sourceforge.net>
In-Reply-To: Your message of "Wed, 04 Dec 2002 18:44:24 PST."
             <CFEAJJEGMGECBCJFLGDBMEHJCJAA.hammer@clarkisland.com>
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


Jake,

I can add a "me,too".

We have about 40 3ware boxes (~30 TB).  These have a single 8
port card running raid 5 (7+1).  We are currently
running XFS on them because we see better scaling performance
versus ext3.  However, the numbers you are reporting look 
similar to ours for 6 clients.

I'm not convinced that the local performance is ruled
out.  How are you testing the local performance?  Are
you running multiple streams?  Are you certain you
are busting cache?  Don't get me wrong, I would love to 
see a performance bug found in NFS that suddenly
makes everything better.  It would make my life
easier.  :-)

Also, are the NFSd's in disk wait?  If they are not, then
this would be a clearer indications that the nfs subsystem
may be to blame.  We usually see all the daemons in
disk wait when we are really pounding one of the these
boxes.

One other note.  We were running software raid (on a 2.2.19
kernel).  After 3ware made some improvements to their
raid 5 implementation, we moved away from it.  It appeared
that we were actually CPU bound with SW raid.  We
are seeing better scaling performance with the HW
raid.  Plus, we can use the hot swap ability of the
card (which for 300+ drives is nice).  :-)

If anyone finds tweaks it would be great to get
them folded into the FAQ.

--Shane

> Hi All,
> 
> I'm working with a 2.4.19 + all Neil Brown 2.4.19 patches on a P4 Xeon
> system, 2048MB ram, uniprocessor kernel. Distro is Debian Woody Stable. Disk
> subsystem is ATA RAID 5, 14 spindles. On writes from 15 100base-T clients
> via a Foundry switch, I am able to see 45MB/sec writes and 60MB/sec reads.
> Clients are DD'ing 10GB files to and from the box simultaneously. Mount =
> mount -o proto=udp,vers=2,wsize=32768,rsize=32768 bigbox:/space
> 
> The problem is on read + write. As soon as the clients switch from read only
> or write only and do BOTH read and write, the CPU pegs and performance drops
> to 3MB/sec (three MB/s)! TOP shows that 4 of the NFSd's are consuming all of
> the CPU. It's like they are contending for some kind of resource like a lock
> or something.
> 
> Any help would be sincerely appreciated. This is very strange behavior. It
> also happens with 2.4.18 + all Neil Brown patches for 2.4.18.
> 
> Thanks,
> 
> Jake Hammer
> 
> 
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: Microsoft Visual Studio.NET 
> comprehensive development tool, built to increase your 
> productivity. Try a free online hosted session at:
> http://ads.sourceforge.net/cgi-bin/redirect.pl?micr0003en
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
