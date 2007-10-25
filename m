From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: nfs performance problem
Date: Thu, 25 Oct 2007 15:53:51 +0200
Message-ID: <200710251553.52138.bernd-schubert@gmx.de>
References: <20071025131029.GH8334@barnabas.schuldei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andreas Schuldei <andreas@schuldei.org>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Il39t-0005ZS-GX
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 06:54:01 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Il39x-0000dJ-Bf
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 06:54:07 -0700
In-Reply-To: <20071025131029.GH8334@barnabas.schuldei.org>
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

Hello Andreas,

On Thursday 25 October 2007 15:10:29 Andreas Schuldei wrote:
> lotta:/var/disks/sda on /var/disks/sda type nfs
> (ro,hard,intr,proto=tcp,rsize=32k,addr=217.213.5.44) lotta:/var/disks/sdb

try to increase rsize and wsize as much as possible, the maximum can be 
adjusted in /proc/fs/nfsd/max_block_size on the nfs server.

>
> but when i then do the same dd again on the client i get
> disappointing 60-70Mbyte/s altogether. from a single disk i get
> ~25Mbytes/s on the client side.
>
> i played with some buffers /proc/sys/net/core/rmem_max and
> /proc/sys/net/core/rmem_default and increased them to 256M on the
> client.
>
> i was suspecting that the nfs server reads the files in too small
> chunks and tried to help it with
>
> for i in a  h i  ; do ( echo $((1024*6)) >
> /sys/block/sd$i/queue/read_ahead_kb ) ; done

Are your partitions on lvm or md? This wouldn't help then, AFAIK for lvm you 
can't do it via /sys, but must always use blockdev

>
> to get it to read in the files in one go.
>
> I would hope to at least double the speed. do
> you have a benchmark tool that can tell me the latency? i tried
> iozone and tried forcing it to only do read tests and did not get
> any helpfull error or output at all.

First of all, what is you *local* performance?


Cheers,
Bernd

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
