From: michael <michael@hq.newdream.net>
Subject: more statd segfault
Date: Mon, 08 Sep 2003 12:58:53 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F5CDF7D.2070608@hq.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19wXW0-00008n-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Sep 2003 18:41:56 -0700
Received: from gollum.dreamhost.com ([66.33.209.16] ident=postfix)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19wU3v-0000Jj-Bp
	for nfs@lists.sourceforge.net; Mon, 08 Sep 2003 15:00:43 -0700
Received: from hq.newdream.net (inez.hq.newdream.net [66.33.200.139])
	by gollum.dreamhost.com (Postfix) with ESMTP id 6D7035B787
	for <nfs@lists.sourceforge.net>; Mon,  8 Sep 2003 12:59:32 -0700 (PDT)
To: NFS List <nfs@lists.sourceforge.net>
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

okay i have tracked down the segfault to here...

void
svc_getreqset (fd_set *readfds)
{
   register u_int32_t mask;
   register u_int32_t *maskp;
   register int setsize;
   register int sock;
   register int bit;

   setsize = _rpc_dtablesize ();
   maskp = (u_int32_t *) readfds->fds_bits;
   for (sock = 0; sock < setsize; sock += 32)
*    for (mask = *maskp++; (bit = ffs (mask)); mask ^= (1 << (bit - 1)))
       svc_getreq_common (sock + bit - 1);
}


the contents of the variables are as follows...
358     in svc.c
(gdb) print *maskp
$13 = 128
(gdb) print mask
$14 = 3221224588
(gdb) print setsize
$15 = 1048566
(gdb) print bit
$16 = 1048566
(gdb) print *readfds
$17 = {fds_bits = {128, 0 <repeats 31 times>}}
(gdb) n 10000

Program received signal SIGSEGV, Segmentation fault.
0x40112e3a in svc_getreqset (readfds=0xbffffc0c) at svc.c:359
359     in svc.c
(gdb) print sock
$37 = 8096
(gdb) print setsize
$38 = 1048566
(gdb) print bit
$39 = -1073741824
(gdb) print maskp
$40 = (u_int32_t *) 0xc0000000
(gdb) print *maskp
Cannot access memory at address 0xc0000000
(gdb)








-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
