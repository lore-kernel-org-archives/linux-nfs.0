From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
 PATCH 9/15] knfsd: add RDMA debug class to rpc_debug bitfield
Date: Fri, 18 May 2007 14:52:41 -0400
Message-ID: <464DF5F9.2090205@oracle.com>
References: <1179510345.23385.122.camel@trinity.ogc.int>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050402060506060404090103"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp7b0-00006D-Tf
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:54:35 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hp7b2-0000rp-CT
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 11:54:37 -0700
In-Reply-To: <1179510345.23385.122.camel@trinity.ogc.int>
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
--------------050402060506060404090103
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Tom-

On the client side, I added a generic debug flag for transports, not a 
specific flag for sockets.  Would you consider doing the same here?

Tom Tucker wrote:
> Add a bit to the rpc_debug bit field for RDMA transport
> debug messages and sysctl definitions for configuration
> and statistics files in /proc/sys/sunrpc/svc_rdma.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  include/linux/sunrpc/debug.h |   15 +++++++++++++++
>  1 files changed, 15 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
> index fc3a5dd..9bf7381 100644
> --- a/include/linux/sunrpc/debug.h
> +++ b/include/linux/sunrpc/debug.h
> @@ -24,6 +24,7 @@ #define RPCDBG_SVCSOCK		0x0100
>  #define RPCDBG_SVCDSP		0x0200
>  #define RPCDBG_MISC		0x0400
>  #define RPCDBG_CACHE		0x0800
> +#define RPCDBG_RDMA		0x1000
>  #define RPCDBG_ALL		0x7fff
>  
>  #ifdef __KERNEL__
> @@ -93,6 +94,20 @@ enum {
>  	CTL_RDMA_MAXINLINEWRITE,
>  	CTL_RDMA_WRITEPADDING,
>  	CTL_RDMA_MEMREG,
> +	CTL_SVCRDMA,
> +	CTL_RDMA_MAX_REQUESTS,
> +	CTL_RDMA_MAX_REQ_SIZE,
> +	CTL_RDMA_ORD,
> +	CTL_RDMA_READ_THROTTLE,
> +	CTL_RDMA_STAT_RECV,
> +	CTL_RDMA_STAT_READ,
> +	CTL_RDMA_STAT_WRITE,
> +	CTL_RDMA_STAT_SQ_STARVE,
> +	CTL_RDMA_STAT_RQ_STARVE,
> +	CTL_RDMA_STAT_RQ_POLL,
> +	CTL_RDMA_STAT_RQ_PROD,
> +	CTL_RDMA_STAT_SQ_POLL,
> +	CTL_RDMA_STAT_SQ_PROD
>  };
>  
>  #endif /* _LINUX_SUNRPC_DEBUG_H_ */
> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


--------------050402060506060404090103
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
url:http://oss.oracle.com/~cel/
version:2.1
end:vcard


--------------050402060506060404090103
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------050402060506060404090103
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050402060506060404090103--
