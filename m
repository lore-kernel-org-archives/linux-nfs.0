From: Chris Tooley <chris@tooley.com>
Subject: Re: Journaling FileSystems w/ NFS
Date: 21 Sep 2002 07:13:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1032610412.1458.2.camel@localhost>
References: <Pine.LNX.4.33.0209201322050.25485-100000@node1.nacs.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Magnus Naeslund(f)" <mag@fbab.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from user-0ccsu93.cable.mindspring.com ([24.206.121.35] helo=localhost.localdomain)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sj9P-0005Yt-00
	for <nfs@lists.sourceforge.net>; Sat, 21 Sep 2002 05:14:19 -0700
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

Be sure to do thorough testing under high load if you decide to use
XFS.  I currently use it for a lot of things, including NFS shares, but
in some installations I've had severe data corruption.  Only the latest
code contains all the fixes.  Release 1.1, the latest "release" code,
did not work for me.  It can work, and when it does it's great, but it
requires a lot of good testing.

Chris Tooley

On Sat, 2002-09-21 at 06:36, Greg Boehnlein wrote:
> On Fri, 20 Sep 2002, Magnus Naeslund(f) wrote:
> 
> > Greg Boehnlein <damin@nacs.net> wrote:
> > > Hello,
> > > Can someone point me to a FAQ on which is the best solution for
> > > running a Journalized Filesystem with NFS support under Linux? We've
> > > tried deploying JFS with RedHat 7.3 and NFS and have run into
> > > problems. From my investigation, it appears that XFS is our best
> > > option for running NFS with +2gig file size support.
> > >
> >
> > Could you elaborate on what troubles you've had?
> > I'm running several boxes that have 1TB partitions and run ReiserFS.
> >
> > One looks like this:
> >
> > [root@fet1a root]# mount
> > /dev/hda6 on / type ext3 (rw,noatime)
> > /dev/sda1 on /storage/disk1 type reiserfs (rw,noatime,notail)
> > /dev/sdb1 on /storage/disk2 type reiserfs (rw,noatime,notail)
> >
> > [root@fet1a root]# df -ht reiserfs
> > Filesystem            Size  Used Avail Use% Mounted on
> > /dev/sda1             1.0T  809G  260G  76% /storage/disk1
> > /dev/sdb1             1.0T   33M  1.0T   1% /storage/disk2
> >
> > Magnus
> 
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
> 
> -- 
>     Vice President of N2Net, a New Age Consulting Service, Inc. Company
>          http://www.n2net.net Where everything clicks into place!
>                              KP-216-121-ST
> 
> 
> 
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
