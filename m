From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.4.18 knfsd load spikes
Date: Thu, 16 May 2002 11:55:48 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CE3F2A4.B326BC5A@amis.com>
References: <Pine.LNX.4.30.0205160949530.8047-100000@whitby.atos-group.nl> <3CE3DEAA.1E6749C5@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Smith <jeff@atheros.com>, Ryan Sweet <rsweet@atos-group.nl>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178PTh-0006M5-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 10:55:49 -0700
To: nfs@lists.sourceforge.net
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

I see the load spikes as well. A ps shows the nfsd processes in the 'DW'
state. DW isn't bad, but when it sits there a long time then the load
jumps up. (could be disk or network related I think?) This seems similar
to what you describe here. Does the load average ramp up to the number
of nfsd threads?

eric


Jeff Smith wrote:
> 
> We are running ext2 filesystems on a Supermicro dual P3 with Serverworks HE
> chipset.  As best I can tell (which probably does not count for much), the CPU
> load comes from all the nfsd's holding off requests while waiting for a cache
> flush.  It happens whenever a particular job is run which slowly reads and
> extends a very large file.  When we suspend the job, every thing returns to
> normal.  When we resume the job, everything continues to run normally for a
> while, but soon begins to bog down the fileserver again.
> 
> Anyway, I hope you are right that you are experiencing a different problem.
> Scheduling downtime around here is difficult, but hopefully in the next few
> weeks I will be able to upgrade the fileservers to 2.4.18 (or 2.4.19?).  In the
> mean time, I'm trying to build a test machine to replicate the problem (and,
> hopefully, verify the fix).
>

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
