From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: Odd errors and bad performance -- NFS/MD/centOS 4
Date: Wed, 16 Nov 2005 14:55:46 -0500 (EST)
Message-ID: <Pine.LNX.4.62.0511161450280.4055@chaos.egr.duke.edu>
References: <Pine.LNX.4.62.0511151326270.806@chaos.egr.duke.edu>
 <17274.28176.342907.560389@cse.unsw.edu.au> <Pine.LNX.4.62.0511160625450.9734@chaos.egr.duke.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcTNo-0000kE-SC
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 11:55:52 -0800
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EcTNn-0001c1-Ny
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 11:55:53 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <Pine.LNX.4.62.0511160625450.9734@chaos.egr.duke.edu>
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

On Wed, 16 Nov 2005 at 8:45am, Joshua Baker-LePain wrote

> On Wed, 16 Nov 2005 at 10:24am, Neil Brown wrote

>> What kernel version, and in particular, what is the timestamp in
>> 'uname -a'.  There was a bug that was fixed around April (?) which
>> affected NFS service of EXT3 filesystems with hash-directories
>> enabled.  This particularly hit redhat as they turn on
>> hash-directories, and so probably affects CentOS too.  You can try
>> using tune2fs to turn off hash-directories and see what happens.
>> That could explain the 'No such file or directory' and 'Stale' errors,
>> but I don't think it explains the slow directory listing.
>
> uname -a says "2.6.9-11.ELsmp #1 SMP Wed Jun 8 17:54:20 CDT 2005".  Also, 
> Seth pointed out to me on another list that this may well be fixed in the 
> most recent centos kernel, due to 
> <https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=158293>.  I'm going to 
> give that kernel a shot.

It didn't help.  'uname -a' now says "2.6.9-22.0.1.ELsmp #1 SMP Thu Oct 27 
13:14:25 CDT 2005", but a client just hung doing 'df' and got this in the 
logs:

RPC: error 512 connecting to server $SERVER
nfs_statfs: statfs error = 512

I've now disabled hash-directories.  Any other hints on places to look?

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
