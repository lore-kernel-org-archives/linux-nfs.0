From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] [PATCH] rpcbind netid declared per-transport
Date: Fri, 31 Aug 2007 10:32:11 -0400
Message-ID: <46D8266B.5060400@oracle.com>
References: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060304080903010909050906"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR9lp-00019N-Pr
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 09:54:57 -0700
Received: from agminet02.oracle.com ([141.146.126.229])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IR7YU-00074m-Vs
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 07:33:03 -0700
Received: from agminet01.oracle.com (agminet01.oracle.com [141.146.126.228])
	by agminet02.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l7VEWt61001562
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 09:32:55 -0500
In-Reply-To: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
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

This is a multi-part message in MIME format.
--------------060304080903010909050906
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> Index: linux-2.6.22/include/linux/sunrpc/clnt.h
> ===================================================================
> --- linux-2.6.22.orig/include/linux/sunrpc/clnt.h
> +++ linux-2.6.22/include/linux/sunrpc/clnt.h
> @@ -92,6 +92,14 @@ struct rpc_procinfo {
>  	char *			p_name;		/* name of procedure */
>  };
>  
> +/*
> + * RFC1833/RFC3530 rpcbind (v3+) well-known netid's.
> + */
> +#define	RPCB_NETID_UDP	"\165\144\160"		/* "udp" */
> +#define	RPCB_NETID_TCP	"\164\143\160"		/* "tcp" */
> +#define	RPCB_NETID_UDP6	"\165\144\160\066"	/* "udp6" */
> +#define	RPCB_NETID_TCP6	"\164\143\160\066"	/* "tcp6" */
> +
>  #ifdef __KERNEL__
>  
>  struct rpc_create_args {

Also I would rename these -- "RPCB_" is used just for identifiers inside 
of rpcb_clnt.c.  Once you move these to a header, they should share the 
same prefix as the other global RPC defines.

--------------060304080903010909050906
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------060304080903010909050906
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------060304080903010909050906
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060304080903010909050906--
