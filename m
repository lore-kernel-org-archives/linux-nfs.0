From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: Re: Stopping NFS, ip address take over, zero-copy NFS for
	2.4.21, and misc
Date: 19 Sep 2003 08:26:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1063977995.2766.4.camel@mosix>
References: <1063900790.8031.9644.camel@localhost.localdomain>
	<3F6A21E1.9090404@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chris Worley <cworley@lnxi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A0LFp-0006wx-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 06:24:57 -0700
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A0LFo-0007ZC-8O
	for nfs@lists.sourceforge.net; Fri, 19 Sep 2003 06:24:56 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <3F6A21E1.9090404@moving-picture.com>
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

On Thu, 2003-09-18 at 16:21, James Pearson wrote:
> Chris Worley wrote:
> >
> > 2) IP address takeover between NFS servers.
> > 
> > With NFS stateless, and not running lock servers, I thought a simple IP
> > address takeover scheme (when an I/O server goes down, another just adds
> > the failed server's IP address as a virtual interface) would allow
> > clients to immediately renegotiate with the same IP address pointing to
> > another NFS server (serving the same partitions).  The take-over is
> > successful: the clients can communicate with the new I/O server, but I
> > get "permission denied" (as root or otherwise) on the NFS mounted
> > partitions most of the time (sometimes it works).
> > 
> > What am I missing?
> 
> I don't know a lot about NFS fail over, but I guess unless the take-over 
> server has a copy (or the same copy) of /var/lib/nfs/rmtab, then you 
> will get "permission denied" - the server needs an entry for each 
> client. I guess it works some of the time as the take-over server has a 
> 'valid' entry in its rmtab file for that client.
>

Yes, i made a little daemon that for each exported directory, generates
a 'directory specific' rmtab file in
/path/to/directory/.nfs_cluster/rmtab. It updates each export directory
every 2 seconds and copies the rmtab to rmtab.old , then generates a
clean rmtab. it has worked fine for me to prevent permission
denied/Stale NFS handles.

Upon the failover, after the filesystem is mounted by the 'takeover
server', the .nfs_cluster/rmtab is processed and added to
/var/lib/nfs/rmtab before exportfs instances are ran on the export
directories.

What are you using for failover?

I use heartbeat.

I also had to make a 2 second delay after IP takeover, for the IP to
actually be working, before I run the exportfs for the newly mounted
filesystem.

Matt Schillinger
mschilli@vss.fsi.com

 
> James Pearson
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
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
