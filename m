From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
 PATCH 9/15] knfsd: add RDMA debug class to rpc_debug bitfield
Date: Wed, 23 May 2007 16:27:38 -0400
Message-ID: <4654A3BA.3010301@oracle.com>
References: <20070521031940.GF7482@sgi.com>
	<C2767CB3.30B42%tom@opengridcomputing.com>
	<20070521041617.GG7482@sgi.com>
	<18001.8854.771127.95716@notabene.brown>
	<4651ACDA.7050207@oracle.com> <20070523151412.GO14076@sgi.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090802020500000402000407"
Cc: Neil Brown <neilb@suse.de>,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqxS8-0008QZ-J3
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 13:29:02 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqxS9-0005zM-KW
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 13:29:03 -0700
In-Reply-To: <20070523151412.GO14076@sgi.com>
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
--------------090802020500000402000407
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Yes, that's basically it.

Greg Banks wrote:
> On Mon, May 21, 2007 at 10:29:46AM -0400, Chuck Lever wrote:
>> Neil Brown wrote:
>>> On Monday May 21, gnb@sgi.com wrote:
>>>> In any case I'm happy to do whatever is necessary in the transport
>>>> patchset,  but I'd appreciate Neil's guidance on which approach he'd
>>>> prefer before I go in with the scalpel.  Neil?
>>> I cannot immediately see the value in having different debug bits for
>>> the socket transport code and the RDMA transport code.  The key
>>> question is "When would you want to see the debugging from one, but
>>> not from the other", and I cannot see when that would be.  Almost
>>> certainly if you are testing one transport, you will not be using the
>>> other, so it will not contribute any noise.
>> That's how I did it in the client transport switch.  One bit enables 
>> debug messages for all transports.
>>
>>> So I suspect we should simply
>>> #define RPCDBG_FACILITY	RPCDBG_SVCSOCK
>> That's expedient, but I suggest you rename the flag to something less 
>> specific to sockets.
> 
> Aah, I see now.  That's very easy.  How's this?
> 
> 
> 
> Rename RPCDBG_SVCSOCK to RPCDBG_SVCXPRT to reflect its
> new more generic nature.
> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> ---
> 
>  include/linux/sunrpc/debug.h |    2 +-
>  net/sunrpc/svcsock.c         |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> Index: linux/include/linux/sunrpc/debug.h
> ===================================================================
> --- linux.orig/include/linux/sunrpc/debug.h	2007-04-26 13:08:32.000000000 +1000
> +++ linux/include/linux/sunrpc/debug.h	2007-05-24 01:09:11.427405573 +1000
> @@ -20,7 +20,7 @@
>  #define RPCDBG_PMAP		0x0020
>  #define RPCDBG_SCHED		0x0040
>  #define RPCDBG_TRANS		0x0080
> -#define RPCDBG_SVCSOCK		0x0100
> +#define RPCDBG_SVCXPRT		0x0100
>  #define RPCDBG_SVCDSP		0x0200
>  #define RPCDBG_MISC		0x0400
>  #define RPCDBG_CACHE		0x0800
> Index: linux/net/sunrpc/svcsock.c
> ===================================================================
> --- linux.orig/net/sunrpc/svcsock.c	2007-05-23 22:39:53.000000000 +1000
> +++ linux/net/sunrpc/svcsock.c	2007-05-24 01:09:15.574878967 +1000
> @@ -73,7 +73,7 @@
>   *
>   */
>  
> -#define RPCDBG_FACILITY	RPCDBG_SVCSOCK
> +#define RPCDBG_FACILITY	RPCDBG_SVCXPRT
>  
>  
>  static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
> 
> Greg.


--------------090802020500000402000407
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


--------------090802020500000402000407
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------090802020500000402000407
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090802020500000402000407--
