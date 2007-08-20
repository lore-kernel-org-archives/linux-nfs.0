From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 00/20] svc: Server Side Transport Switch
Date: Mon, 20 Aug 2007 11:20:00 -0500
Message-ID: <20070820162000.15224.65524.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INA2J-0006N2-Iu
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:27 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INA2N-0003ri-1A
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:23:31 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 257337C0CC
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:23:21 -0500 (CDT)
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

This patchset represents an update to the previously published 
version. The most significant changes are a renaming of the 
transport switch data structures and functions based on a 
recommendation from Chuck Lever. Code cleanup was also done in the
portlist implementation based on feedback from Trond. Additionally, 
the synopsis for the register/unregister services were changed
to return errors and module reference counting was added. 

I've included the original description below for new reviewers.

This patchset implements a sunrpc server side pluggable transport 
switch that supports dynamically registered transports. 

The knfsd daemon has been modified to allow user-mode programs 
to add a new listening endpoint by writing a string
to the portlist file. The format of the string is as follows:

<transport-name> <port>

For example,

# echo rdma 2050 > /proc/fs/nfsd/portlist

Will cause the knfsd daemon to attempt to add a listening endpoint on 
port 2050 using the 'rdma' transport.

Transports register themselves with the transport switch using a
new API that has the following synopsis:

int svc_register_transport(struct svc_sock_ops *xprt)

The text transport name is contained in a field in the xprt structure.
A new service has been added as well to take a transport name
instead of an IP protocol number to specify the transport on which the 
listening endpoint is to be created. This function is defined as follows:

int svc_create_svcsock(struct svc_serv, char *transport_name, 
                       unsigned short port, int flags);

The existing svc_makesock interface was left to avoid impacts to existing 
servers. It has been modified to map IP protocol numbers to transport 
strings.

-- 
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
