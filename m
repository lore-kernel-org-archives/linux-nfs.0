From: Tavis Barr <tb62@columbia.edu>
Subject: [Fwd: Re: NFS-HOWTO]
Date: 19 Mar 2002 13:18:22 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1016561902.2031.23.camel@vaio>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-yxruY3mDnDbLcwWgRTWb"
Received: from 24-29-106-192.nyc.rr.com ([24.29.106.192] helo=localhost.localdomain)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nOBp-0002eH-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 10:18:29 -0800
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--=-yxruY3mDnDbLcwWgRTWb
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Andrew Ryan had a good question for me below that I don't know the
answer to.  When a file gets modified and left the same size twice
within one second, its mtime stays the same and all other attributes
stay the same, so the NFS server does not see that it has been altered. 
At least this is my understanding of the bug.  Some things that I don't
know because I'm not familiar enough with the NFS internals:

*What data structure reflects that the file has been altered?  Is it the
inode number, or some field within the inode?
*This was supposedly a 2.5 fix item; the issue is that mtime does not
have a granularity finer than one second.  What subsystem does the fix
go into?  The VFS layer?  Has there been any work done on it?


Thanks,
Tavis


--=-yxruY3mDnDbLcwWgRTWb
Content-Disposition: inline
Content-Description: Forwarded message - Re: [NFS] NFS-HOWTO
Content-Type: message/rfc822

Return-Path: <andrewr@collab.net>
Received: from smithers.sfrn.dnai.com (smithers.sfrn.dnai.com
	[208.59.199.26]) by menyapa.cc.columbia.edu (8.9.3/8.9.3) with ESMTP id
	NAA18571 for <tb62@columbia.edu>; Sat, 16 Mar 2002 13:38:23 -0500 (EST)
Received: from sideshow-bob.sfrn.dnai.com (sideshow-bob.sfrn.dnai.com
	[208.59.199.20]) by smithers.sfrn.dnai.com (8.11.2/8.11.2) with ESMTP id
	g2GIYr103114 for <tb62@columbia.edu>; Sat, 16 Mar 2002 10:34:53 -0800 (PST)
Received: from collab.net (208-59-198-7.s7.tnt1.dsfr.ca.dialup.rcn.com
	[208.59.198.7]) by sideshow-bob.sfrn.dnai.com (8.11.3/8.11.3) with ESMTP id
	g2GIbQ904164 for <tb62@columbia.edu>; Sat, 16 Mar 2002 10:37:26 -0800 (PST)
	(envelope-from andrewr@collab.net)
Message-ID: <3C939132.F11E3D66@collab.net>
Date: Sat, 16 Mar 2002 10:38:42 -0800
From: Andrew Ryan <andrewr@collab.net>
X-Mailer: Mozilla 4.73 [en] (Win98; U)
X-Accept-Language: en
MIME-Version: 1.0
To: Tavis Barr <tb62@columbia.edu>
Subject: Re: [NFS] NFS-HOWTO
References: <1016245811.1540.14.camel@vaio>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Nice job on the FAQ. It's been helpful for us setting up our NFS clients.

In 7.10, "File Corruption When Using Multiple Clients", you state that "If a
file has been modified within one second of its previous modification and left
the same size, it will continue to generate the same inode number." I don't
understand this statement -- it seems to me that the inode number of a file
should not change when a file is modified. I can see the mtime changing, but
not the inode number.

Also, this bug is new to me -- it's not in the previous NFS HOWTO, and I think
it deserves a lot more explanation as to why it happens now and also some
ideas for workarounds, both in 2.5 (where it will presumably be solved the
right way) and before 2.5 (where perhaps there is a hack that could be
applied).

Finally, is this bug a client-side bug, or does it just affect people using
linux as an NFS server?


thanks,
andrew
p.s. It would be nice if you could get the Netapp folks to contribute a
section in the interop chapter.


Tavis Barr wrote:

> Attached is a draft of the latest NFS-HOWTO, in HTML format.  (Put it
> all in the same directory and go to index.html).  Comments welcome.
>
> Cheers,
> Tavis

--=-yxruY3mDnDbLcwWgRTWb--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
