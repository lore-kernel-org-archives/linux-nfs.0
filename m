From: BigShamy24@aol.com
Subject: NFS Server:7.1/Client: Sol8
Date: Mon, 10 Jun 2002 18:40:09 EDT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <126.11f11e17.2a3684c9@aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from imo-m08.mx.aol.com ([64.12.136.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17HXpn-0000Yk-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Jun 2002 15:40:23 -0700
Received: from BigShamy24@aol.com
	by imo-m08.mx.aol.com (mail_out_v32.5.) id 6.126.11f11e17 (4241)
	 for <nfs@lists.sourceforge.net>; Mon, 10 Jun 2002 18:40:10 -0400 (EDT)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello,
I am using Redhat 7.1 as my NFS server. I have edited /etc/exports and when I 
ran "rpcinfo -p localhost" I got all the daemons and their ports correctly.

On the client side, I have Solaris 8. Everytime I try to mount I get the 
following error.
nfs mount: x.x.x.x: : RPC: Rpcbind failure - RPC: Unable to receive nfs 
mount: retrying: /dump
And it keeps on trying.I have checked everything that I can think off. From 
portmap to hosts.allow/.deny

I am clueless! Any help plz>Thanks  


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas - http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
