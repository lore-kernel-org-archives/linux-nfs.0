From: Philippe Troin <phil@fifi.org>
Subject: Re: Journaling FileSystems w/ NFS
Date: 21 Sep 2002 12:14:52 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87lm5vupcj.fsf@ceramic.fifi.org>
References: <Pine.LNX.4.33.0209201322050.25485-100000@node1.nacs.net>
Reply-To: <nfs@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tantale.fifi.org ([216.27.190.146])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17spiT-00040i-00
	for <nfs@lists.sourceforge.net>; Sat, 21 Sep 2002 12:14:57 -0700
To: Greg Boehnlein <damin@nacs.net>
In-Reply-To: <Pine.LNX.4.33.0209201322050.25485-100000@node1.nacs.net>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Greg Boehnlein <damin@nacs.net> writes:

> Let me bring you up to speed on what we are doing, and provide an accurate
> idea of what our needs and requirements are. Instead of backing our data
> up directly to tape, we instead dump it to a large 320 Gig, RAID-5
> partition on a Linux box. That, in turn, is backed up to tape on a regular
> basis and taken offsite. Recent growth of data on some of our "Cobalt Raq"
> servers has forced us to upgrade to a filesystem that can handle file
> sizes of greater than 2 gigs. (Why Cobalt doesn't split their backup
> archives into multiple pieces is beyond me). On occasion, this partition
> needs to be accessible via NFS for other Servers and workstations.
> Obviously with a file system of that size, a journaling system would be
> advantageous.
> 
> So, we need three main things:
> 1. Journaling File System
> 2. Large file support
> 3. NFS Compatibility
> 
> I had suggested XFS to my Operations Manager, but he decided to try using
> JFS, as it was an included option in RedHat 7.3. Installation went
> beautifully, and everything was peachy, until we tried to export that
> file-system via NFS. Doing so caused the load average on the box to
> skyrocket.. Apparently, NFS and JFS don't get along very well together.
> 
> Our solution? Use XFS. ;) However, there do appear to be issues between
> JFS and NFS... Not sure where, or what, but I thought I'd mention it.

I'd be curious to know why you did not choose the "easy" solution:
ext3. It is journalled, it has LFS support, and works flawlessly with
NFS.

Phil.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
