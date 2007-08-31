From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] [PATCH] rpcbind netid declared per-transport
Date: Fri, 31 Aug 2007 12:27:34 -0400
Message-ID: <46D84176.5020807@oracle.com>
References: <EXNANE01Mb1s7nlT2Nq00000219@exnane01.hq.netapp.com>
	<46D820F8.6040309@oracle.com>
	<1188570399.6649.83.camel@heimdal.trondhjem.org>
	<46D825EB.90801@oracle.com>
	<1188573228.6649.100.camel@heimdal.trondhjem.org>
	<46D835F4.4030703@oracle.com>
	<EXNANE01hjJ8uT6Ssuo00000243@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050704040900080609030504"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR9Ma-00060u-Vc
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 09:28:53 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IR9Me-0003yF-3t
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 09:28:57 -0700
In-Reply-To: <EXNANE01hjJ8uT6Ssuo00000243@exnane01.hq.netapp.com>
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
--------------050704040900080609030504
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> "RPCB_" prefix: They're (with this patch) part of the rpcbind api. The prefix
> seems logical to me... 

Well, that's a fair argument, since the idea of netid is defined in RFC 
1833, which is about rpcbind specifically.  However, the globally scoped 
RPC-related identifiers are usually named RPC_... and you are now making 
use of these things in the transport layer as well as in rpcbind.

It's a nit, I guess.

> when you say "the same as the other RPC..." do you
> mean they should be "RPC_NETID_..."?

Yes.

> RPCB_MAXNETIDLEN: Sure, I'll move it. It is, after all, a limit on the string
> passed as the netid, i.e. part of the API. But let me ask this. It really isn't
> necessary, the code in rpcbind can easily accommodate longer strings. Is
> it worth coding the extra generality? The reason I didn't is because (as the
> comment mentions) there aren't any longer strings defined by any RFC.

We need to know the maximum size to compute the largest possible size of 
the RPC buffer needed for the request.  See the definition of 
RPCB_netid_sz.  Those are all added together to get the largest possible 
request size, and that's used to compute the largest possible buffer size.

Using a macro documents what the heck that number is.  "4?  4 what?"  I 
was asked at the time this was submitted to use macros instead of 
open-coded integers, and I tend to agree that looks better.

> clnt.h vs msg_prot.h: After discovering the rpcbind calls defined in clnt.h,
> and also seeing rpc goop in there, it felt more correct than msg_prot.h,
> which is pretty much about rpc marshaling and error codes. All the other
> rpcbind stuff is in clnt.h, and most all clnt's need to call rpcbind to find
> their port. That's my rationale.

The rpcbind function calls are defined in clnt.h because they are part 
of the RPC client API, specific to Linux.

Netids are standardized on-the-wire marshaled values, so they definitely 
belong in msg_prot.h, which as you say, contains marshaling and error 
code definitions.

--------------050704040900080609030504
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


--------------050704040900080609030504
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------050704040900080609030504
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050704040900080609030504--
