From: Ryan Sweet <rsweet@atos-group.nl>
Subject: Re: 2.4.18 disk i/o load spikes was: re: knfsd load spikes
Date: Fri, 17 May 2002 11:46:51 +0200 (MEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0205171011100.10147-100000@whitby.atos-group.nl>
References: <3CE3F81B.50FC7F61@atheros.com>
Reply-To: Ryan Sweet <rsweet@atos-group.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Whiting <ewhiting@amis.com>, <nfs@lists.sourceforge.net>,
   Ryan Sweet <rsweet@atos-group.nl>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [62.58.73.254] (helo=ats-core-0.atos-group.nl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178eVP-0002ur-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 02:58:36 -0700
To: Jeff Smith <jeff@atheros.com>
In-Reply-To: <3CE3F81B.50FC7F61@atheros.com>
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


I did some additional testing, and in my case I do not think the problem
I am having is nfs related.  Thus perhaps we can move this discussion to
lkml.  I will probably post a summary there later today.

I can reproduce the issue at will when the file server is not busy using
the slowspeed.c program that was attached in  previous message.

If I run it with 10 streams at 65k against the external RAID array
(adaptec 29160 controller), it will eventually (within 20 minutes) spiral
into severe pain (load > 30).

Looking at /proc/scsi/aic7xxx/2, I can see that the Commands Active is
always pegged at 8.  The Command Openings reads 245 (the controller depth
of 253-8). Looking at the kernel config, the aic7xx driver was built with
the old default TCQ depth of 8, but it should really be 253 (I think).

I tested another system, slower, only single cpu, but with the same
controller.  I used the same kernel and could easily reproduce the problem
with about 6 streams.  Then I rebuilt the same kernel only changed the TCQ
depth to 253.   In that configuration the system does very well up to
about 20 - 25 streams, at which point it starts to wait too long.  Looking
in /proc/scsi/aic7xx on that system the Commands Active is pegged at 64,
and Command Openings at 0.  When the system is idle, Command Openings is
at 64.  Note that I can still cause the problem to happen with 20+ streams
of I/O.  That hardly seems optimal.

So first on my list is to reboot the filer with the aic7xxx set to TCQ
depth of 253.

My questions are still:
1) Why if the kernel (as reported by dmesg) has the TCQ set to 253, does
it cap it at 64?

2) What causes it to spiral to unusable loads when the TCQ is full?



-- 
Ryan Sweet <ryan.sweet@atosorigin.com>
Atos Origin Engineering Services
http://www.aoes.nl




_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
