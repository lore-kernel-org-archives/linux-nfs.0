From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: statd segfaults
Date: Wed, 19 Feb 2003 11:08:22 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15954.51958.993033.937277@notabene.cse.unsw.edu.au>
References: <3E51D8C8.8000905@newdream.net>
	<shsof5a542k.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael <michael@newdream.net>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lHnL-0002QV-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 16:09:03 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <trond.myklebust@fys.uio.no>) (for <michael@newdream.net>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Wed, 19 Feb 2003 11:08:51 +1100
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on  February 18
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

On  February 18, trond.myklebust@fys.uio.no wrote:
> >>>>> " " == michael  <michael@newdream.net> writes:
> 
>      > ) = 74 sendmsg(4, {msg_name(16)={sin_family=AF_INET,
>      > sin_port=htons(2670), sin_addr=inet_addr("127.0.0.1")}},
>      > msg_iov(1)=[{"\336^\313\2\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
>      > 32}], msg_controllen=24, msg_control=0x8051c20, , msg_flags=0},
>      > 0) = 32
> 
> That looks a bit strange. Why would msg_controllen/msg_control be set
> on an RPC call? Are you sure that your statd is linked to the standard
> RPC library routines in glibc?

Because statd (and the rpc server libraries in general) wants to
tell the kernel about the packet is is repling to, make sure it gets
the source address right.  IP_PKTINFO.  I am in the middle of a thread
about it on linux-kernel because I don't think the kernel handles it
quite right.

However that doesn't explain the SEGFAULT.  Have you tried 'ltrace' on
statd.  What does it show?

NeilBrown



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
