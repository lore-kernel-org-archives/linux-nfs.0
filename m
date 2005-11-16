From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: Odd errors and bad performance -- NFS/MD/centOS 4
Date: Wed, 16 Nov 2005 08:45:55 -0500 (EST)
Message-ID: <Pine.LNX.4.62.0511160625450.9734@chaos.egr.duke.edu>
References: <Pine.LNX.4.62.0511151326270.806@chaos.egr.duke.edu>
 <17274.28176.342907.560389@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcNbt-0001u4-EL
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 05:46:01 -0800
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EcNbr-0005bN-6d
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 05:46:01 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17274.28176.342907.560389@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
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

On Wed, 16 Nov 2005 at 10:24am, Neil Brown wrote

> On Tuesday November 15, jlb17@duke.edu wrote:
>>
>> Given RH's absurd attitude toward XFS, I decided it was time to bite the
>> bullet and transition to ext3.  So I took a snapshot backup, reinstalled,
>> and tried to run in the same setup.  Performance with ext3 was a joke.
>> Despite days of tweaking (all detailed on nahant-list), ext3 topped out at
>> about 34 MB/s writing.
>
> Sounds like the 3WARE driver is busted in recent kernels...

Not really -- I didn't tell you the whole story.  I also tested ext2 and 
XFS (via the centosplus kernel):

      write   read
      -----   ----
ext2    81    180
ext3    34    222
XFS    109    213

Given that, I tried ext3 with an external journal, but even that didn't 
help.

> What kernel version, and in particular, what is the timestamp in
> 'uname -a'.  There was a bug that was fixed around April (?) which
> affected NFS service of EXT3 filesystems with hash-directories
> enabled.  This particularly hit redhat as they turn on
> hash-directories, and so probably affects CentOS too.  You can try
> using tune2fs to turn off hash-directories and see what happens.
> That could explain the 'No such file or directory' and 'Stale' errors,
> but I don't think it explains the slow directory listing.

uname -a says "2.6.9-11.ELsmp #1 SMP Wed Jun 8 17:54:20 CDT 2005".  Also, 
Seth pointed out to me on another list that this may well be fixed in the 
most recent centos kernel, due to 
<https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=158293>.  I'm going 
to give that kernel a shot.

> Writing to NFS usually is slow as the server has to commit everything
> to disk before returning.  You can try 'data=journal' as a mount
> option.  It sometimes makes NFS writes faster, but it might make local
> writes slower.

These systems are pure file servers, so local performance is of no 
concern.  I'll give data=journal a shot.  Thanks!

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
