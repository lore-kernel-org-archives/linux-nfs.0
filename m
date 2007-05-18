From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 0/15] knfsd: a transport driver for RDMA
Date: Fri, 18 May 2007 12:44:24 -0500
Message-ID: <1179510264.23385.113.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp6VB-0000jj-AZ
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:44:29 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp6VD-0007qF-R7
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:44:32 -0700
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


These 15 patches are an experimental RDMA transport driver 
for knfsd. They have been tested quite extensively on 2.6.18, 
but less so on this latest version (2.6.21). The transport 
driver plugs into an earlier transport switch that Greg and Peter 
have since tuned up and posted here. 

[RFC,PATCH 1/15] knfsd: add NFSD_RDMA as an option to kconfig
[RFC,PATCH 2/15] knfsd: add RDMA transport module to sunrpc makefile
[RFC,PATCH 3/15] knfsd: intitialize RDMA transport in sunrpc
[RFC,PATCH 4/15] knfsd: map null socket to SOCK_STREAM in svc_max_payload
[RFC,PATCH 5/15] knfsd: support RDMA transport in svc_create_socket
[RFC,PATCH 6/15] knfsd: nfs3svc_decode_writeargs assumes data follows header
[RFC,PATCH 7/15] knfsd: create RDMA transport in nfssvc
[RFC,PATCH 8/15] knfsd: map null socket to SOCK_STREAM in svcauth_unix
[RFC,PATCH 9/15] knfsd: add RDMA debug class to rpc_debug bitfield
[RFC,PATCH 10/15] knfsd: RDMA transport module initialization
[RFC,PATCH 11/15] knfsd: RDMA transport core
[RFC,PATCH 12/15] knfsd: RDMA transport recvfrom 
[RFC,PATCH 13/15] knfsd: RDMA transport sendto 
[RFC,PATCH 14/15] knfsd: RDMA transport mashalling logic
[RFC,PATCH 15/15] knfsd: RDMA transport debug macros

Tom


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
