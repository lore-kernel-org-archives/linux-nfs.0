From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Question on NFS server timing out
Date: Wed, 25 Jun 2003 09:26:33 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16120.56873.142665.95413@gargle.gargle.HOWL>
References: <001101c33a76$77b37f30$88693fd1@WEASEL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19UxBS-0003wZ-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 16:26:42 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <sn@codon.com>) (for <nfs@lists.sourceforge.net>) By tone With
	Smtp ; Wed, 25 Jun 2003 09:26:33 +1000
To: "Steve Wolfe" <sn@codon.com>
In-Reply-To: message from Steve Wolfe on Tuesday June 24
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

On Tuesday June 24, sn@codon.com wrote:
> 
> 
>    I have an NFS server which feeds seven front-end web servers, and am
> having a bit of trouble.  Late at night, when traffic is very low, the web
> servers will (one at a time) turn off Apache, then move their logs from
> the day to the NFS server - "cat /logs/access_log >>
> /nfs/logs/access_log", etc..
> 
>    It takes approximately three minutes for each server to complete the
> task, and one web server will do that every ten minutes, so there's a good
> break in between.  The problem I'm having is that nearly every night, one
> (or more) web servers will report errors such as:
> 
> kernel: nfs: server fs not responding, timed out
> 
>    From 'cat', I'll get I/O errors.  Here's where it's interesting:  While
> I do *occasionally* get these messages during the day while traffic to the
> site is high (4,000,000+ hits/day), they're almost entirely coming at
> night when there's very little traffic, and moving the log files is the
> only thing running of any consequence.  During that time, the loads on the
> NFS server range from 0.40 to 10+.  I'll try and include as much
> information as I can:

If you are getting I/O errors from cat then you are presumably
mounting with the "soft" option.  This is almost always wrong.  Use
hard,intr.

I'm guessing that the high load during the days is a read-mostly load.
moving the log files in a write-mostly load.  Presumably your nfs
server isn't coping with writes as fast as you would like.

You are probably using the "sync" export option.  This is normally a
good thing.  However if you are happy to risk loosing recently written data if
the fileserver crashes (which you might be in your situation) you
could replace "sync" with "async" and get faster writes.

> 
>    The kernel version on the file server is 2.4.21, and the web servers
> are 2.4.20 or 2.4.21.  NFS utils is 1.01.  The server has a gigE
> connection to a switch, and each of the web servers has a 100 mbit
> connection to it.  The front-end servers are dual-proc machines, ranging
> from 1.26 GHz P3's, AthlonMP 2000+'s, and 2.4 GHz P4 Xeons, each with a
> gig of RAM.  The NFS server is a 2x 650 MHz P3, with a hardware RAID 5
> array.

What filesystem?  How is it configured?
If you are using ext3, then data=journal will speed up nfs writes.
If you are using data=journal, how big is the journal and how big are
the log files that you write?

> 
>   I'm perfectly willing to simply throw more CPU at the file server, but
> I'd like to be more comfortable as to the causes of these problems before
> I throw a few thousand dollars at it.
> 
>    I increased the instances of the NFS daemon to 30, and here's the
> result of my /proc/net/rpc/nfsd file:
> 
> rc 7189 16880044 311057687
> fh 42430 325891894 0 84 1087
> io 3989924770 2696872349
> th 30 363910 14551.150 3574.590 2512.890 1963.700 1230.320 950.690 735.050
> 620.750 480.530 1622.160

It doesn't hurt to add a few more threads, though I cannot promise it
will help.
If all seven clients are busy they will only get about threads each,
they can probably make use of more than that.  I would probably try 60
and see what happens.

> ra 60 21593454 289563 157689 105808 77308 60445 48612 40040 33983 29316 0
> net 327944920 327944920 0 0
> rpc 327944920 0 0 0 0
> proc2 18 0 6577 56 0 1912621 0 57972 0 57004 8832 16593 666 8702 0 15 0
> 113576 5
> proc3 22 0 106764969 5544375 106804625 60744573 380 26020237 10147319
> 504561 4918 11 0 476056 4346 41 162 2129294 0 23467 23463 0 6569504

26020237 read requests
10147319 write requests

so presumably there are lots of writes during the day too.  Maybe they
aren't all close together.

> 
>   Before starting the NFS daemon, I'm setting the send/receive network
> buffers to a megabyte.

Thats is a no-op for 2.4.20 and later.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
