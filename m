From: "Gobikrishnan Sundharraj" <gsundharraj@novell.com>
Subject: NFS server export problem
Date: Sun, 19 Oct 2003 00:06:16 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <sf91d589.045@prv-mail20.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AB6kJ-00056A-00
	for <nfs@lists.sourceforge.net>; Sat, 18 Oct 2003 23:08:55 -0700
Received: from prv-mail20.provo.novell.com ([137.65.81.122])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1AB6kE-0003uy-TQ
	for nfs@lists.sourceforge.net; Sat, 18 Oct 2003 23:08:50 -0700
To: <nfs@lists.sourceforge.net>
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

Hello,

I installed RedHat 9 on my system and I am trying to setup an NFS
server. 

On the NFS client, I got the error:

"mount ... failed, reason given by server: permission denied"

and I have traced the problem to the "export" on the server.

On the server, the /proc/fs/nfs/exports does not show what I configured
to be exported (empty).

/etc/exports file has read permission for the root, and it has the
following entry:
/home/<user>/<dir>      a.b.c.0/24(rw, sync)

On the server, rpcinfo -p produces the following:
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    391002    2   tcp  32769  sgi_fam
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32776  nlockmgr
    100021    3   udp  32776  nlockmgr
    100021    4   udp  32776  nlockmgr
    100011    1   udp    654  rquotad
    100011    2   udp    654  rquotad
    100011    1   tcp    657  rquotad
    100011    2   tcp    657  rquotad
    100005    1   udp    662  mountd
    100005    1   tcp    665  mountd
    100005    2   udp    662  mountd
    100005    2   tcp    665  mountd
    100005    3   udp    662  mountd
    100005    3   tcp    665  mountd

Everything seems to be fine and I don't know why the exports is not
working for me..

Can you please help?

Kernel version: 2.4.20-8
nfs-utils version: 1.0.5-1

Thanks,
Gobi.




-------------------------------------------------------
This SF.net email sponsored by: Enterprise Linux Forum Conference & Expo
The Event For Linux Datacenter Solutions & Strategies in The Enterprise 
Linux in the Boardroom; in the Front Office; & in the Server Room 
http://www.enterpriselinuxforum.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
