From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: statd segfaults
Date: Wed, 9 Apr 2003 10:56:06 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16019.28582.756584.968791@notabene.cse.unsw.edu.au>
References: <3E51D8C8.8000905@newdream.net>
	<shsof5a542k.fsf@charged.uio.no>
	<15954.51958.993033.937277@notabene.cse.unsw.edu.au>
	<3E932AB7.2010002@newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1933tG-0007mc-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Apr 2003 17:56:38 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <michael@newdream.net>) (for <trond.myklebust@fys.uio.no>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Wed, 9 Apr 2003 10:56:29 +1000
To: michael <michael@newdream.net>
In-Reply-To: message from michael on Tuesday April 8
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

On Tuesday April 8, michael@newdream.net wrote:
> I have included an ltrace of statd which shows the segfault. any 
> guidance as far as what is going on right before the segfault would be 
> greatly appreciated.  The segfaults are happening many times a day on a 
> large number of servers. the enviornment is debian 3.0. LEt me know if i 
> have left out and needed info.


Hmmm... I don't fully understand..

I receives a 76 byte message,

> 09:32:42 SYS_socketcall(17, 0xbffff654, 0x4014fe48, 0x08050f68, 16) = 76

It makes a UDP socket, does all these IOCTL's....

> 09:32:43 <... ioctl resumed> )                    = 0
> 09:32:43 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
> 09:32:43 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
> 09:32:43 <... ioctl resumed> )                    = 0
> 09:32:43 ioctl(6, 35091, 0xbffff5fc <unfinished ...>
> 09:32:43 SYS_ioctl(6, 35091, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
> 09:32:43 <... ioctl resumed> )                    = 0
> 09:32:43 ioctl(6, 35093, 0xbffff5fc <unfinished ...>
> 09:32:43 SYS_ioctl(6, 35093, 0xbffff5fc, 0xbffff5fc, 0xbffff61c) = 0
> 09:32:43 <... ioctl resumed> )                    = 0

and then closes that socket.

> 09:32:43 close(6 <unfinished ...>
> 09:32:43 SYS_close(6)                             = 0
> 09:32:43 <... close resumed> )                    = 0

And now it starts looking at the message and appears to decode an
SM_UNMON requeust and report that something was
wrong because it didn't think it was monitoring anything.

> 09:32:43 xdr_string(0x08051098, 0xbffff648, 1024, 0x4015664d, 0x4014fe48) = 1
> 09:32:43 xdr_string(0x08051098, 0xbffff64c, 1024, 0x40125506, 0xbffff648) = 1
> 09:32:43 xdr_int(0x08051098, 0xbffff650, 1024, 0x40125506, 0xbffff648) = 1
> 09:32:43 xdr_int(0x08051098, 0xbffff654, 1024, 0x40125506, 0xbffff648) = 1
> 09:32:43 xdr_int(0x08051098, 0xbffff658, 1024, 0x40125506, 0xbffff648) = 1
> 09:32:43 vsnprintf("Received SM_UNMON request from d"..., 1024, "Received SM_UNMON request from %"..., 0xbffff5ec) = 82
> 09:32:43 time(0xbffff1d8 <unfinished ...>
> 09:32:43 SYS_time(0xbffff1d8, 32, 0xbffff1d8, 5, 0xbffff1dc) = 0x3e92f9ab
> 09:32:43 <... time resumed> )                     = 1049819563
> 09:32:43 localtime(0xbffff1d8)                    = 0x401544a0
> 09:32:43 fprintf(0x4014d380, "%02d/%02d/%04d %02d:%02d:%02d %s"..., 4, 8, 2003, 9, 32, 43, "rpc.statd" <unfinished ...>
> 09:32:43 SYS_write(2, "04/08/2003 09:32:43 rpc.statd[16"..., 12104/08/2003 09:32:43 rpc.statd[16103]: Received SM_UNMON request from dali for 10.3.34.97 while not monitoring any hosts.
> ) = 121
> 09:32:43 <... fprintf resumed> )                  = 121

Then it sends a reply ... 
> 09:32:43 svc_sendreply(0x08050f58, 0x08049f84, 0x0804fe48, 0x0804d5d3, 0x08050f58 <unfinished ...>
> 09:32:43 xdr_int(0x08051098, 0x0804fe48, 0x08051098, 0x0eb86024, 0x0eb86024) = 1
> 09:32:43 SYS_socketcall(16, 0xbffff574, 0x4014fe48, 28, 0x08051098) = 28
> 09:32:43 <... svc_sendreply resumed> )            = 1

and then starts decoding another message, even though it hasn't
received another message.  The pattern of strings and ints
suggests an SM_UNMON request again.
> 09:32:43 xdr_string(0x08051098, 0xbffff648, 1024, 0x40122b45, 0x4014fe48) = 1
> 09:32:43 xdr_string(0x08051098, 0xbffff64c, 1024, 0x40125506, 0xbffff648) = 1
> 09:32:43 xdr_int(0x08051098, 0xbffff650, 1024, 0x40125506, 0xbffff648) = 1
> 09:32:43 xdr_int(0x08051098, 0xbffff654, 1024, 0x40125506, 0xbffff648) = 1
> 09:32:43 xdr_int(0x08051098, 0xbffff658, 1024, 0x40125506, 0xbffff648) = 1

And then it goes SIGSEGV when it should be printing out that message
again.
> 09:32:43 --- SIGSEGV (Segmentation fault) ---
> 09:32:43 +++ killed by SIGSEGV +++

This looks like something that will be rather hard to debug remotely.
I really want to run statd under gdb and have a look around when it
dies.  If you could do that and at least give me the output of
"where" when it dies, that would help.

Also a
   tcpdump -w /tmp/dumpfile -s1500 udp port XXXX
where XXXX is the port that statd is listening on might help too.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
