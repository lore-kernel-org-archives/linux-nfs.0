From: michael <michael@newdream.net>
Subject: Re: more statd segfault
Date: Thu, 11 Sep 2003 19:05:23 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F6129E3.6040604@newdream.net>
References: <3F5CDF7D.2070608@hq.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xdJg-0005AA-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Sep 2003 19:05:44 -0700
Received: from gollum.dreamhost.com ([66.33.209.16] ident=postfix)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19xdJg-0006tI-EL
	for nfs@lists.sourceforge.net; Thu, 11 Sep 2003 19:05:44 -0700
Received: from newdream.net (inez.hq.newdream.net [66.33.200.139])
	by gollum.dreamhost.com (Postfix) with ESMTP id 74CE25B783
	for <nfs@lists.sourceforge.net>; Thu, 11 Sep 2003 19:05:43 -0700 (PDT)
To: NFS List <nfs@lists.sourceforge.net>
In-Reply-To: <3F5CDF7D.2070608@hq.newdream.net>
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

I finally tracked down the statd segfault that had been plaguing me for 
sometime.

statd calls sunrpc code which is in libc on debian. this code loops 
through all possible file descriptors and in my case if the number of 
fds per process is set higher then 8096 it segfaults.

for the archives here is the code that segfaults:

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
     for (mask = *maskp++; (bit = ffs (mask)); mask ^= (1 << (bit - 1)))
       svc_getreq_common (sock + bit - 1);
}


keywords: statd segfault sun rpc file lock ulimit

michael



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
