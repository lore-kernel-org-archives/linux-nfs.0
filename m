From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: statd segfaults
Date: 18 Feb 2003 10:30:11 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsof5a542k.fsf@charged.uio.no>
References: <3E51D8C8.8000905@newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18l450-0001B4-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 01:30:22 -0800
To: michael <michael@newdream.net>
In-Reply-To: <3E51D8C8.8000905@newdream.net>
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

>>>>> " " == michael  <michael@newdream.net> writes:

     > ) = 74 sendmsg(4, {msg_name(16)={sin_family=AF_INET,
     > sin_port=htons(2670), sin_addr=inet_addr("127.0.0.1")}},
     > msg_iov(1)=[{"\336^\313\2\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
     > 32}], msg_controllen=24, msg_control=0x8051c20, , msg_flags=0},
     > 0) = 32

That looks a bit strange. Why would msg_controllen/msg_control be set
on an RPC call? Are you sure that your statd is linked to the standard
RPC library routines in glibc?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
