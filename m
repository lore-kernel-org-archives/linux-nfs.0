From: Ryan Sweet <rsweet@atos-group.nl>
Subject: Re: 2.4.18 disk i/o load spikes
Date: Sat, 18 May 2002 09:14:11 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0205180854110.29675-100000@core-0>
References: <49CA7FE2A83A33459A2CD27E99E90EFB0BAE9C@poexmb1.conoco.net>
Reply-To: Ryan Sweet <rsweet@atos-group.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>, <rsweet@atos-group.nl>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [62.58.73.254] (helo=ats-core-0.atos-group.nl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178ybE-0003Sv-00
	for <nfs@lists.sourceforge.net>; Sat, 18 May 2002 00:25:56 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
In-Reply-To: <49CA7FE2A83A33459A2CD27E99E90EFB0BAE9C@poexmb1.conoco.net>
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

On Fri, 17 May 2002, Heflin, Roger A. wrote:
>
> When you run it with the 10 streams, that is on the local disk with
> no nfs?

Yes, I first tested the local disks only, then verified that the symptoms
were the same with nfs.

> And also, besides the load rising, what happens to the
> io rates when things start to spiral?

tcp networking, cpu utilisation are fine, responsiveness from anything
depending upon the filesystems in question, however, really starts to
suck.  User sessions with home dirs on the filer all grind to a halt, nfs
timeouts happen all over the place, and even doing an ls takes forever.

> I have not been able to duplicate
> it under 2.4.19 with the latest NFS patches with limited testing.

Running the same tests on another 2.4.18 system, with the same mb/cpu/ram,
but with a promise controller and four ata/100 ide drives in software
raid5 I was also unable to reporduce the problem.  The system gets well
and truly loaded, and I/O rates on the promise software raided drives are
not spectacular, but the system remains responsive and most importantly
the performance is much more smooth, not so many bursts of I/O, with long
waits in between.

> 	I am the author of slowspeed.c, I have been able to duplicate it
> 	on 2.2.19 with nfs, I believe I was able to duplicate it on a local
> 	disk with no nfs, but I cannot duplicate things slowing down
> 	always with things on the local disk.   On 2.2.19 it looks like

When we used 2.2.18 (9 months ago?), we did not have this problem, though
as I mentioned in my original post, our client mix (and usage pattern) has
changed significantly.

BTW, the progrm segfaults with more than 35 streams.  Running another one
in another dir seems ok though.


_______________________________________________________________
Hundreds of nodes, one monster rendering program.
Now that's a super model! Visit http://clustering.foundries.sf.net/

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
