From: Andreas Schuldei <andreas@schuldei.org>
Subject: Re: nfs performance problem
Date: Thu, 25 Oct 2007 16:39:45 +0200
Message-ID: <20071025141913.GD4499@jakobus.spotify.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Bernd Schubert <bernd-schubert@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Il3sW-00020X-FH
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 07:40:08 -0700
Received: from petrus.schuldei.org ([81.27.3.162] helo=barnabas.schuldei.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Il3sZ-0003Js-Nt
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 07:40:14 -0700
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

* Bernd Schubert (bernd-schubert@gmx.de) [071025 15:54]:
> Hello Andreas,
> 
> On Thursday 25 October 2007 15:10:29 Andreas Schuldei wrote:
> > lotta:/var/disks/sda on /var/disks/sda type nfs
> > (ro,hard,intr,proto=tcp,rsize=32k,addr=217.213.5.44) lotta:/var/disks/sdb
> 
> try to increase rsize and wsize as much as possible, the maximum can be 
> adjusted in /proc/fs/nfsd/max_block_size on the nfs server.

the with a max_block_size and rsize=512k i did not achive a noticable performance impact.
increasing it to 2M decreased the performance to 12-12Mbytes/s per disk. do i need to adjust more 
tuneables to benefit from the increased size?


> > i was suspecting that the nfs server reads the files in too small
> > chunks and tried to help it with
> >
> > for i in a  h i  ; do ( echo $((1024*6)) >
> > /sys/block/sd$i/queue/read_ahead_kb ) ; done
> 
> Are your partitions on lvm or md? This wouldn't help then, AFAIK for lvm you 
> can't do it via /sys, but must always use blockdev

they are on xfs directly on disk, no lvm or md involved.

> > to get it to read in the files in one go.
> >
> > I would hope to at least double the speed. do
> > you have a benchmark tool that can tell me the latency? i tried
> > iozone and tried forcing it to only do read tests and did not get
> > any helpfull error or output at all.
> 
> First of all, what is you *local* performance?

i mentioned that i get 50Mbyte/s out of each disk, even
when doing the dd on all four disks at the same time.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
