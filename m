From: Steve Fosdick <lists@pelvoux.nildram.co.uk>
Subject: Re: Hang Problem - Linux Server, HP-UX Client
Date: Wed, 16 Jul 2003 19:35:19 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030716183519.GA20136@pelvoux.gotadsl.co.uk>
References: <20030716120142.GA18956@pelvoux.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pelvoux.gotadsl.co.uk ([62.3.242.73])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19cr8B-0003gl-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Jul 2003 11:36:00 -0700
Received: from localhost
	([127.0.0.1] helo=pelvoux ident=fozzy)
	by pelvoux.gotadsl.co.uk with esmtp (Exim 3.36 #1 (Debian))
	id 19cr7X-0005JM-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Jul 2003 19:35:19 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <20030716120142.GA18956@pelvoux.gotadsl.co.uk>; from lists@pelvoux.nildram.co.uk on Wed, Jul 16, 2003 at 13:01:42 +0100
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

Further to my previous message here is part of the output of tcpdump 
running on the NFS server and capturing UDP port 2409 at the time 
client complains the server is no longer responding:

17:40:30.705564 spitfire.nfs > moorland.1438258734: reply ok 112 getattr
DIR 40700 ids 0/3 sz 0x0000001e8  (DF)
17:40:30.705804 moorland.1438258735 > spitfire.nfs: 128 getattr fh
Unknown/1
17:40:30.705859 spitfire.nfs > moorland.1438258735: reply ok 112 getattr
DIR 40700 ids 0/3 sz 0x000000090  (DF)
17:40:30.706106 moorland.1438258736 > spitfire.nfs: 136 lookup fh
Unknown/1 "0205"
17:40:30.706177 spitfire.nfs > moorland.1438258736: reply ok 232 lookup
fh Unknown/1 (DF)
17:40:30.722560 moorland.1438258737 > spitfire.nfs: 152 commit fh
Unknown/1 17367040 bytes @ 0x001fd0000
17:40:30.722632 spitfire.nfs > moorland.1438258737: reply ok 128 commit
(DF)
17:40:30.729689 moorland.1438258738 > spitfire.nfs: 860 write fh
Unknown/1 [|nfs]
17:40:30.729884 spitfire.nfs > moorland.1438258738: reply ok 136 write
[|nfs] (DF)
17:40:30.730182 moorland.1438258739 > spitfire.nfs: 152 commit fh
Unknown/1 0 bytes @ 0x00306a000
17:40:30.730242 spitfire.nfs > moorland.1438258739: reply ok 128 commit
(DF)
17:40:31.194906 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 33609:1480@0+)
17:40:41.194960 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 33725:1480@0+)
17:40:43.694927 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 33767:1480@0+)
17:40:48.694994 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 33832:1480@0+)
17:40:58.695014 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 33986:1480@0+)
17:41:18.695127 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 34252:1480@0+)
17:41:23.695079 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 34299:1480@0+)
17:41:33.695137 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 34399:1480@0+)
17:41:53.695236 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 34723:1480@0+)
17:42:13.695771 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 34928:1480@0+)
17:42:23.695328 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 35028:1480@0+)
17:42:43.695375 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 35260:1480@0+)

Here is another piece of tcpdump output, this time after the server has
been rebooted and the client should still be trying to write the same
file:

17:59:43.667811 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 47468:1480@0+)
18:00:03.668106 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 47937:1480@0+)
18:00:23.668423 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 48124:1480@0+)
18:00:31.165567 moorland.1438258740 > spitfire.nfs: 116 getattr fh
Unknown/1
18:00:31.165637 spitfire.nfs > moorland.1438258740: reply ok 112 getattr
DIR 40755 ids 0/0 sz 0x000000170  (DF)
18:00:31.165966 moorland.1438258741 > spitfire.nfs: 116 fsinfo fh
Unknown/1
18:00:31.166020 spitfire.nfs > moorland.1438258741: reply ok 80 fsinfo
rtmax 8192 rtpref 8192 wtmax 8192 wtpref 8192 dtpref 4096 (DF)
18:00:31.166245 moorland.1438258742 > spitfire.nfs: 116 fsstat fh
Unknown/1
18:00:31.166316 spitfire.nfs > moorland.1438258742: reply ok 84 fsstat
tbytes 0x5d1de0000 fbytes 0x58ba6f000 abytes 0x58ba6f000 (DF)
18:00:31.166884 moorland.1438258743 > spitfire.nfs: 116 getattr fh
Unknown/1
18:00:31.166940 spitfire.nfs > moorland.1438258743: reply ok 112 getattr
DIR 40755 ids 0/0 sz 0x0000005b0  (DF)
18:00:43.668505 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 48342:1480@0+)
18:01:03.668682 moorland.1438257340 > spitfire.nfs: 1472 write fh
Unknown/1 [|nfs] (frag 48598:1480@0+)

Do either of these shed any light?

Steve.


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
