From: Andreas Behnert <abehn@gmx.net>
Subject: Re: high load
Date: Tue, 22 Apr 2003 10:32:08 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EA4FE08.30105@gmx.net>
References: <20030418194844.GB29491@oppie.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.gmx.de ([213.165.64.20] helo=mail.gmx.net)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 197tCR-0001vE-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Apr 2003 01:32:23 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20030418194844.GB29491@oppie.phys.uwm.edu>
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

Phil Garcia wrote:
> Hi,
> 
> We've come across a problem that seems related to the interaction
> between NFS and a 3ware 7500-8 running RAID 5 with one hot spare.  We
> have a test program that opens a file and then loops, writing up to
> 255 bytes to the file and then sleeping for up to 10 seconds.  We run
> around 200 instances of the program simultaneously for about 25
> minutes.
> 
> When we run the processes on 200 separate slaves, writing to a
> (reiserfs) directory under the 3ware controller, the load on the
> server shoots up to over 20 and then gradually declines over the next
> 5 minutes or so.

The problem may be caused by ReiserFS:
If you are using kernel 2.2.x and ReiserFS 3.5.x - ReiserFS for
kernel 2.2.x is REALLY broken. We had similar problems here that
ended up in ReiserFS destroying itself, reproducible! Patches
from ftp.namesys.com didn't help at all. At that time ReiserFS
was nothing more than something to play with.
Can't say anything about kernel 2.4.x and ReiserFS 3.6.x - after
the 3.5.x desasters we moved back to ext2 and are now running ext3
with "data=journal" on our NFS servers without a single problem ...


Regards,
Andreas



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
