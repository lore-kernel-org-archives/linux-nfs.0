From: Andreas Schuldei <andreas@schuldei.org>
Subject: Re: nfs performance problem
Date: Sat, 27 Oct 2007 11:25:04 +0200
Message-ID: <20071027092504.GC25508@jakobus.schuldei.org>
References: <20071025131029.GH8334@barnabas.schuldei.org>
	<200710251553.52138.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Bernd Schubert <bernd-schubert@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ilhv2-0001vt-Gj
	for nfs@lists.sourceforge.net; Sat, 27 Oct 2007 02:25:24 -0700
Received: from petrus.schuldei.org ([81.27.3.162] helo=barnabas.schuldei.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ilhv6-0007He-QL
	for nfs@lists.sourceforge.net; Sat, 27 Oct 2007 02:25:30 -0700
In-Reply-To: <200710251553.52138.bernd-schubert@gmx.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

* Bernd Schubert (bernd-schubert@gmx.de) [071027 01:39]:
> Hello Andreas,
> 
> On Thursday 25 October 2007 15:10:29 Andreas Schuldei wrote:
> > lotta:/var/disks/sda on /var/disks/sda type nfs
> > (ro,hard,intr,proto=tcp,rsize=32k,addr=217.213.5.44) lotta:/var/disks/sdb
> 
> try to increase rsize and wsize as much as possible, the maximum can be 
> adjusted in /proc/fs/nfsd/max_block_size on the nfs server.

i cant increase this to more then 1M. is that the hard limit?



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
