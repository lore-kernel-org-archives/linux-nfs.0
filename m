From: Erik Walthinsen <omega@pdxcolo.net>
Subject: Re: NAS server avalanche overload
Date: Wed, 03 Mar 2004 14:02:23 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078351343.821.28.camel@localhost>
References: <1078302718.825.67.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyeXB-00019g-MH
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 14:08:09 -0800
Received: from mail.pdxcolo.net ([64.146.134.17] helo=palantir.pdxcolo.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AyeRf-0003SM-7u
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 14:02:27 -0800
Received: from omegacs.net ([216.99.212.251] helo=omicron.omegacs.net)
	by palantir.pdxcolo.net with asmtp (Exim 3.35 #1 (Debian))
	id 1AyeRe-0006lI-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Mar 2004 14:02:26 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1078302718.825.67.camel@localhost>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Greg Banks said:
> Are you using the "async" export option on the server?  It causes
> similar symptoms when used with large NFS writes.  Use "sync".

Mount options as reported by /proc/mounts are:
rw,noatime,rsize=3D4096,wsize=3D4096,intr,soft,noac,tcp

I'm pretty sure the default here is async, as I had sync on there
earlier and it actually caused a noticeable drop in performance.

What I'm wondering is if the default bdflush settings are putting a hard
cap on how much data can be write-cached, forcing the system to block
writes too early.  With 512MB of RAM, say half available as write-cache,
even at the rate of 5MB/sec, we should be able to run for almost a
minute with complete disk starvation before things start to wedge.  And
since this doesn't look like complete starvation at all (graphs show
I/O's are completing the whole time), it should last even longer.

If anyone has any ideas on what to tweak in bdflush, it seems that there
*is* some pattern in the spikes, with them occurring at 11:25pm and
12:00am every day for at least the last 3 days.

Philippe Gramouli=E9 said:
> Is there anything that prevent you from running a 2.4.25 kernel ?

It's a production machine with those 60+ virtual machines running on it,
so the only opportunity I have to change anything of this sort is during
our quarterly downtime, the next one being early April.

Williamson, Jay (John G) said:
> Hi. I have no experience with your particular setup but have had
> similar problems when our clients were running a pre-2.4.20 kernel and
> using UDP for the NFS mounts. If that fits your client setup then try
> either upgrading the kernel or switching to TCP.

We're using TCP, as it also had performance advantages in our early
tests.

David Dougall said:
> My experience is that ext3 is dreadfully slow and RAID5 is dreadfully
> slow.  These 2 combined can cause significant problems.  The
> suggestions that have come from the list before are to change to
> RAID10 and use another filesystem such as reiserfs or xfs.  I saw
> significant speedup moving away from ext3.

The NAS itself is using reiserfs, only the virtual machines are using
ext3.  The question there is what kind of read/write load differences
one might have between the two.  Certainly there's a possibility that
the journaling writes have something to do with it, but I wouldn't think
they would cluster to the degree things seem to be.

RAID 1+0 is an option with the 8506-12, but the migration is extremely
painful.  We have to acquire a whole new set of disks (would probably
get 6), construct the array, then copy half a TB of data across.  Much
of the data is sparse files, so the process would take even longer.  At
least a large chunk of it is non-production files (mirrors), so probably
1/2 to 2/3 can be done without downtime.

- Omega
  aka Erik Walthinsen
  omega@pdxcolo.net



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
