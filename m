From: Jeff Smith <jeff@atheros.com>
Subject: Re: 2.4.18 knfsd load spikes
Date: Thu, 16 May 2002 11:19:07 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CE3F81B.50FC7F61@atheros.com>
References: <Pine.LNX.4.30.0205160949530.8047-100000@whitby.atos-group.nl> <3CE3DEAA.1E6749C5@atheros.com> <3CE3F2A4.B326BC5A@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Ryan Sweet <rsweet@atos-group.nl>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.atheros.com ([65.212.155.130] helo=atheros.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178PqZ-0000g9-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 11:19:27 -0700
To: Eric Whiting <ewhiting@amis.com>
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

It is exactly as you describe.  Before this started happening, I would run 16
nfsd threads.  And when it started happening the load would creep up to 16 as
the server grinds to a halt.  To mitigate this, I've dropped down to 2 nfsd
threads so that the machine does not die before I can locate and kill the
"offending" job.

Jeff

Eric Whiting wrote:
> 
> I see the load spikes as well. A ps shows the nfsd processes in the 'DW'
> state. DW isn't bad, but when it sits there a long time then the load
> jumps up. (could be disk or network related I think?) This seems similar
> to what you describe here. Does the load average ramp up to the number
> of nfsd threads?
> 
> eric
> 
> Jeff Smith wrote:
> >
> > We are running ext2 filesystems on a Supermicro dual P3 with Serverworks HE
> > chipset.  As best I can tell (which probably does not count for much), the CPU
> > load comes from all the nfsd's holding off requests while waiting for a cache
> > flush.  It happens whenever a particular job is run which slowly reads and
> > extends a very large file.  When we suspend the job, every thing returns to
> > normal.  When we resume the job, everything continues to run normally for a
> > while, but soon begins to bog down the fileserver again.
> >
> > Anyway, I hope you are right that you are experiencing a different problem.
> > Scheduling downtime around here is difficult, but hopefully in the next few
> > weeks I will be able to upgrade the fileservers to 2.4.18 (or 2.4.19?).  In the
> > mean time, I'm trying to build a test machine to replicate the problem (and,
> > hopefully, verify the fix).
> >

-- 
Jeff Smith                                  Atheros Communications, Inc.
Hardware Manager                            529 Almanor Avenue
(408) 773-5257                              Sunnyvale, CA  94086

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
