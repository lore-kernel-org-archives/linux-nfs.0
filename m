From: campbellm@cia.com.au
Subject: NFS and privileged ports
Date: Fri, 1 Apr 2005 12:54:00 +1000
Message-ID: <20050401025400.GD12443@cia.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DHCKp-0002Fr-EV
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 18:56:35 -0800
Received: from mx.mail.com.au ([203.17.36.233])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1DHCKp-0004h5-0Q
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 18:56:35 -0800
Received: from mail.cia.com.au ([203.17.36.17] helo=cia.com.au)
	by mx.mail.com.au with smtp (Exim 4.34)
	id 1DHCJm-0003YQ-LO
	for nfs@lists.sourceforge.net; Fri, 01 Apr 2005 12:55:30 +1000
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

I am creating a ACLs for RBAC systems (specifically LIDS and grsecurity) that are
running NFS servers and clients, but am having problems with daemons
opening privileged ports, seemingly at random. Portmap I know listens on
port 111, no problem there. But the following open privileged ports upon starting
up which I can't see any way of locking down:

portmap (aside from 111)
rpc.statd
rpc.nfsd
rpc.mountd
rpcinfo

I presume they are opened for the purposes of rpc communications between
each other. I have set rpc.lockd to listen on a defined, unprivileged
port at boot up, which is ok, and have set rpc.mountd also to listen on
a non-privileged port in the init script (which it does, but also it
tries to open a privileged port). The system I am running is Debian
Woody 3.0 with 2.4.29, NFS v3 compiled into the kernel. The portmap
daemon is that shipped with Woody (5.2), and the other daemons are
standard with Debian Woody as well. I would prefer not to use binary
versions if possible, as that adds to the overhead when doing package
updates. Currently, I have to allow a large range of ports (500-1024)
for the above mentioned daemons through my ACLs, otherwise they won't
start. Does anyone know if it possible to stop these daemons opening
privileged ports? Or at least restricting them to particular ports?


Cheers for any help,

Campbell


-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
