From: Todd Weaver <todd@m2n.com>
Subject: Re: some programs hang when run over nfs.
Date: Tue, 9 Apr 2002 18:25:09 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0204091823080.19524-100000@minstrel.m2n.com>
References: <3CB38D35.16746195@collab.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 63-224-62-148.dsl.uswest.net ([63.224.62.148] helo=mail.m2n.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16v6rM-0002Sk-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Apr 2002 18:25:16 -0700
To: Andrew Ryan <andrewr@collab.net>
In-Reply-To: <3CB38D35.16746195@collab.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, 9 Apr 2002, Andrew Ryan wrote:
> I would check that lockd is running on the client and server, with
> rpcinfo -p, and that it is not firewalled off.

Here is the output of rpcinfo -p on the Workstation and the Server

Workstation:
ws04:/etc# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp   1024  nlockmgr
    100021    3   udp   1024  nlockmgr
    100007    2   udp    791  ypbind
    100007    1   udp    791  ypbind
    100007    2   tcp    794  ypbind
    100007    1   tcp    794  ypbind
    100024    1   udp    707  status
    100024    1   tcp    709  status
    100003    2   udp   2049  nfs
    100003    2   tcp   2049  nfs
ws04:/etc#

Server:
todd@ws02~ $ rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100003    2   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100005    1   udp    946  mountd
    100005    2   udp    946  mountd
    100005    1   tcp    949  mountd
    100005    2   tcp    949  mountd
    100004    2   udp    630  ypserv
    100004    1   udp    630  ypserv
    100004    2   tcp    633  ypserv
    100004    1   tcp    633  ypserv
    100009    1   udp    632  yppasswdd
 600100069    1   udp    634
 600100069    1   tcp    636
    100007    2   udp    641  ypbind
    100007    1   udp    641  ypbind
    100007    2   tcp    644  ypbind
    100007    1   tcp    644  ypbind
    100021    1   udp   2408  nlockmgr
    100021    3   udp   2408  nlockmgr
    100024    1   udp    997  status
    100024    1   tcp    999  status
todd@ws02~ $

I would add that all these programs worked fine before I did an apt-get
update ; apt-get dist-upgrade which upgraded about 35 packages (so I am
not sure what caused the problem).


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
