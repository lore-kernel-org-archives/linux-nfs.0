From: "Derek Labian" <derek@ioerror.com>
Subject: High Performance NFS
Date: Thu, 31 Oct 2002 14:28:34 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <011501c2811c$16327c70$1400005b@ipservices1.ioerror.com>
References: <E187Law-0001u2-00@usw-sf-list2.sourceforge.net>
Reply-To: <derek@ioerror.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [66.250.32.135] (helo=mail1.la.ioerror.com)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 187LvJ-0004LV-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 12:28:13 -0800
Received: from bloat (adsl-66-141-3-5.dsl.hstntx.swbell.net [66.141.3.5])
	by mail1.la.ioerror.com (8.12.3/8.12.3) with SMTP id g9VKTmbc019242
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 12:29:49 -0800 (PST)
	(envelope-from derek@ioerror.com)
To: <nfs@lists.sourceforge.net>
In-Reply-To: <E187Law-0001u2-00@usw-sf-list2.sourceforge.net>
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

I'm really looking for a high performance NFS solution
and determining the bottlenecks is key for this upgrade.

We currently have 2 Dedicated NFS servers.  Supermicro 
boxes w/ Dual P3 1Ghz, 1GB RAM and an adaptec 2100s w/
128MB cache connected to Dell u160 powervaults.

All the servers are connected through gigabit ethernet.

It seems we really start peaking out the disks at about
12-13MB a sec.  This seems kind of slow, but the accesses
are not sequential because of the volume.  The drives
are 10k RPM btw.

The servers run FreeBSD (latest) and distribute files to 
8 other servers.  The average file size is around 5MB
but peaks up to several hundred MB's depending on whats
happening on any given day.

Also, when peak traffic occurs, the NFS processes all
get stuck in disk access, and the requests start queing
up. 

For this reason, we have modified the NFSD and NFS Header
file thats part of the Kernel to support much  more then
20 Daemons.

This help performance dramatically.

Additionally, we have tried different levels of read ahead
blocks, block sizes etc.  Read aheads above 1 work fine
until the load peaks up.  (Since its reading more data)

Also, smaller then 8k blocks seem to slow it down and
larger then 8k blocks seem to slow it down.

Hence we use 8k blocks, 1 read ahead block, UDP.

So, is there any suggestings for getting more performance
out of these things, or if we simply need to upgrade further
what are the suggestions for high performance NFS at a 
reasonable cost.

Derek


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
