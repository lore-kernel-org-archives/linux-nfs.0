From: Matthew Mitchell <matthew@geodev.com>
Subject: More about nfsd/lockd hang in 2.4.20+NFS_ALL
Date: Fri, 13 Jun 2003 08:46:35 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EE9D5BB.6040600@geodev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gateway2.geodev.com ([64.45.165.170] ident=[mLmEsSfcp0DYhepU4iEiIJ3zzThyWbsS])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Qowu-00016x-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 06:50:36 -0700
Received: from geodev.com (smithers.geodev.com [192.168.201.178])
	by gateway2.geodev.com (8.11.6/8.11.6) with ESMTP id h5DDkXv08788
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 08:46:33 -0500
To: nfs@lists.sourceforge.net
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

(see my earlier message from June 10 for more information)

So this morning it happened again.  Seems that when the operator tried 
to log in to the disk server as himself, it NFS-mounted his home 
directory for him.  This is a loopback mount.  The message printed out 
by lockd was
	lockd: rejected NSM callback from 7f000001:32769

(4 times).  This is in fs/lockd/svcproc.c and svc4proc.c, in the 
function nlmsvc_proc_sm_notify.  I am not sure what the difference 
between "nlm" and "nlm4" is, but I bet someone on this list knows...

In any event, I noticed this right as it was happening, so I was able to 
kill -9 the operator's login and the system recovered.  Symptoms of the 
hang were like I had seen before -- it looks like this is capable of 
hanging every NFS service running on the machine.

For now I just changed the automount map so this won't happen.  I can't 
imagine that this behavior is correct, so perhaps someone would be 
interested in helping me understand what is going on?  There should be 
no technical reason why a loopback NFS mount should fail, even though 
you might not really want to do it for performance reasons.

The code looks like this:

         if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
          || ntohs(saddr.sin_port) >= 1024) {
                 printk(KERN_WARNING
                         "lockd: rejected NSM callback from %08x:%d\n",
                         ntohl(rqstp->rq_addr.sin_addr.s_addr),
                         ntohs(rqstp->rq_addr.sin_port));
                 return rpc_system_err;
         }

In this case, though, the rq_addr.sin_addr.s_addr is that of loopback, 
as it says in the message (7f000001 => 127.0.0.1).  It would appear that 
this is a lock notify that's supposed to be called when a client 
reconnects to a server, but it thinks it's being called with some 
impossible values.

Am I on the mark here?  Something that might be relevant: this server 
was recently pressed into use as the server for these volumes. 
Previously, it was mounting them (home directories) from another server, 
which died.  Perhaps it has some old lock information lying around, and 
when it tries to connect to itself as a client, it tries to reacquire 
its locks?  Or perhaps it is something more innocuous.

In any case, comments or help appreciated.

-- 
Matthew Mitchell
Systems Programmer/Administrator            matthew@geodev.com
Geophysical Development Corporation         phone 713 782 1234
1 Riverway Suite 2100, Houston, TX  77056     fax 713 782 1829



-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
