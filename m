From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: Re: An NFS-HA HOWTO anyone? WAS> Re: Stopping NFS, ip address
	take over, zero-copy NFS for 2.4.21, and misc
Date: 22 Sep 2003 09:24:42 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1064240684.15988.4.camel@mosix>
References: <Pine.LNX.4.33L2.0309201819250.29042-100000@jeprox.qsr.com.ph>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1Rdr-0000l5-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Sep 2003 07:26:19 -0700
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A1Rdq-0002D9-4y
	for nfs@lists.sourceforge.net; Mon, 22 Sep 2003 07:26:18 -0700
To: ian "sison (mailing list)" <ian.s@qsr.com.ph>
In-Reply-To: <Pine.LNX.4.33L2.0309201819250.29042-100000@jeprox.qsr.com.ph>
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

On Sat, 2003-09-20 at 05:22, ian sison (mailing list) wrote:
> 
> On Fri, 19 Sep 2003 rnews@tasking.nl wrote:
> 
> > Chris Worley <cworley@lnxi.com> wrote:
> > | 2) IP address takeover between NFS servers.
> > |
> > | With NFS stateless, and not running lock servers, I thought a simple IP
> > | address takeover scheme (when an I/O server goes down, another just adds
> > | the failed server's IP address as a virtual interface) would allow
> > | clients to immediately renegotiate with the same IP address pointing to
> > | another NFS server (serving the same partitions).  The take-over is
> > | successful: the clients can communicate with the new I/O server, but I
> > | get "permission denied" (as root or otherwise) on the NFS mounted
> > | partitions most of the time (sometimes it works).
> >
> > You need to migrate the entries in /var/lib/nfs/rmtab to the new
> > machine. Also, when the device number on the new machine differs
> > from the device number on the old machine, you need to use the "fsid"
> > option in /etc/exports, to make sure the file handles don't change.
> 
> This is important information, and it should go into a howto. NFS-HA is a
> very common requirement nowadays, and there's very little information i've
> seen on the net except for the Mission Critical Linux site.
> 
I need to update info on the page, and quite honestly, i think the info
i have is buggy.. (I will update this week), but i have a document
showing how I achieve 'Active-Active' HA NFS over Shared SCSI.. Mainly,
it's by replicating rmtab entries by storing mountpoint specific rmtab
entries on the shared storage mountpoint... 

the address is:

http://chilli.linuxmds.com/~mschilli/NFS/

Bookmark the page, and I promise by mid week, i'll have it updated.. I
will post to the mailing list when the update is complete.

Matt Schillinger
mschilli@vss.fsi.com
> 
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
