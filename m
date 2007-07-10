From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 00/20] svc: sunrpc server side transport switch
Date: Tue, 10 Jul 2007 00:27:11 -0500
Message-ID: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88Mh-00073o-EY
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:23 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88Mk-0004po-VQ
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:27 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 3B0277C75F
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:20 -0500 (CDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This patchset implements a sunrpc server side pluggable transport switch.
It includes recommendations from SGI and others and supports dynamically 
registered transports. 

The knfsd daemon has also been modified to allow user-mode programs to add a 
new listening endpoint by writing a string to the portlist file. The 
format of the string is as follows:

<transport-name> <port>

For example,

# echo rdma 2050 > /proc/fs/nfsd/portlist

causes the knfsd daemon to to add a listening endpoint on 
port 2050 using the 'rdma' transport.

Transports register themselves with the transport switch using a
new API that has the following synopsis:

void svc_register_transport(struct svc_sock_ops *xprt)

A new sunrpc export has been added to take a transport name instead of 
an IP protocol number to specify the transport on which the listening 
endpoint is to be created. This function is defined as follows:

int svc_create_svcsock(struct svc_serv, char *transport_name, 
		       unsigned short port, int flags);

The existing svc_makesock interface was left to avoid impacts to existing 
servers. It has been modified to map IP protocol numbers to transport 
strings.

This transport switch has been tested wth the recently posted RDMA transport 
driver. A git tree is available with the server side transport and RMDA 
transport driver at: git://linux-nfs.org/~tomtucker/nfs-rdma-dev-2.6.git

The git tree and this patchset are based on 2.6.22-rc6.

-- 
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
