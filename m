From: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Subject: RE: Problems with large number of clients and reads
Date: Mon, 9 Jun 2008 08:20:59 -0500
Message-ID: <0122F800A3B64C449565A9E8C297701002D75D9A@hoexmb9.conoco.net>
References: <1212519001.24900.14.camel@hololw58> <48487F79.4000607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Dean Hildebrand" <seattleplus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman2.ppco.com ([138.32.41.14]:57634 "EHLO mailman2.ppco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759311AbYFINVG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2008 09:21:06 -0400
Received: from bvlextrd2.conoco.net (bvlextrd2.conoco.net [138.32.41.13])
	by mailman2.ppco.com (Switch-3.2.7/Switch-3.2.7) with ESMTP id m59DL4kM010473
	for <linux-nfs@vger.kernel.org>; Mon, 9 Jun 2008 08:21:04 -0500
In-Reply-To: <48487F79.4000607@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(I dislike Outlook....  Apologize if I end up messing up the formatting
of the message)
 

The file system is XFS, about 250 GB per server.  I would say that yes
it is managing the cache on the server(s) in question.  The servers in
question have 16 GB of memory, and the files being served are 1.9 GB,
about 5 each per server.


-----Original Message-----
From: Dean Hildebrand [mailto:seattleplus@gmail.com] 
Sent: Thursday, June 05, 2008 7:06 PM
To: Weathers, Norman R.
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problems with large number of clients and reads

>What is the file system?  It is the one managing the cache on the
server.
>Dean





Norman Weathers wrote:
> Hello all,
>
> We are having some issues with some high throughput servers of ours.
>
> Here is the issue, we are using a vanilla 2.6.22.14 kernel on a node
> with 2 Dual Core Intels (3 GHz) and 16 GB of ram.  The files that are
> being served are around 2 GB each, and there are usually 3 to 5 of
them
> being read, so once read they fit into memory nicely, and when all is
> working correctly, we have a perfectly filled cache, with almost no
disk
> activity.
>
> When we have large NFS activity (say, 600 to 1200 clients) connecting
to
> the server(s), they can get into a state where they are using up all
of
> memory, but they are dropping cache.  slabtop is showing 13 GB of
memory
> being used by the size-4096 slab object.  We have two ethernet
channels
> bonded, so we see in excess of 240 MB/s of data flowing out of the
box,
> and all of the sudden, disk activity has risen to 185 MB/s.  This
> happens if we are using 8 or more nfs threads.  If we limit the
threads
> to 6 or less, this doesn't happen.  Of course, we are starving
clients,
> but at least the jobs that my customers are throwing out there are
> progressing.  The question becomes, what is causing the memory to be
> used up by the slab size-4096 object?  Why when all of the sudden a
> bunch of clients ask for data does this object grow from 100 MB to 13
> GB?  I have set the memory settings to something that I thought was
> reasonable.
>
> Here is some more of the particulars:
>
> sysctl.conf tcp memory settings:
>
> # NFS Tuning Parameters
> sunrpc.udp_slot_table_entries = 128
> sunrpc.tcp_slot_table_entries = 128
> vm.overcommit_ratio = 80
>
> net.core.rmem_max=524288
> net.core.rmem_default=262144
> net.core.wmem_max=524288
> net.core.wmem_default=262144
> net.ipv4.tcp_rmem = 8192 262144 524288
> net.ipv4.tcp_wmem = 8192 262144 524288
> net.ipv4.tcp_sack=0
> net.ipv4.tcp_timestamps=0
> vm.min_free_kbytes=50000
> vm.overcommit_memory=1
> net.ipv4.tcp_reordering=127
>
> # Enable tcp_low_latency
> net.ipv4.tcp_low_latency=1
>
> Here is a current reading from a slabtop of a system where this error
is
> happening:
>
> 3007154 3007154 100%    4.00K 3007154        1  12028616K size-4096
>
> Note the size of the object cache, usually it is 50 - 100 MB (I have
> another box with 32 threads and the same settings which is bouncing
> between 50 and 128 MB right now).
>
> I have a lot of client boxes that need access to these servers, and
> would really benefit from having more threads, but if I increase the
> number of threads, it pushes everything out of cache, forcing
re-reads,
> and really slows down our jobs.
>
> Any thoughts on this?
>
>
> Thanks, 
>
> Norman Weathers
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   
