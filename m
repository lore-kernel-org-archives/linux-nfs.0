From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Use of delayed request information in nlmsvc_lookup_host
Date: Thu, 15 Nov 2007 08:55:46 -0500
Message-ID: <473C4FE2.1090402@oracle.com>
References: <473B3D0B.3060204@oracle.com>	<1195065798.7584.37.camel@heimdal.trondhjem.org>	<473B45C9.4060708@oracle.com>	<1195069262.7584.54.camel@heimdal.trondhjem.org>	<473B5278.7090408@oracle.com>
	<18235.41907.383911.722103@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060608040400010904040204"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsfEh-0006GM-Mh
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 05:58:32 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsfEl-00012F-Cf
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 05:58:33 -0800
In-Reply-To: <18235.41907.383911.722103@notabene.brown>
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
--------------060608040400010904040204
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Wednesday November 14, chuck.lever@oracle.com wrote:
>> Trond Myklebust wrote:
>>> On Wed, 2007-11-14 at 14:00 -0500, Chuck Lever wrote:
>>>> That's correct.  I'm just trying to understand why, historically, 
>>>> rq_daddr was just the 32-bit address and not a full sockaddr to begin 
>>>> with.  There may be something we're missing, like "we didn't want to add 
>>>> another large field to this structure due to memory alignment or 
>>>> allocation efficiency concerns".  :-)
>>> Actually, rq_daddr by definition pretty much has to be of the same
>>> address family as rq_addr, since they are the two endpoints for the same
>>> socket. 
>>>
>>> However I can't see where rq_addr is being initialised for UDP sockets.
>>> That is sort of worrying given that it is used among other things by the
>>> nfsd duplicate reply cache...
>> That's the other half of my question.  Why isn't nlmsvc_lookup_host 
>> using rq_addr (without the d)?
> 
> Git is your friend.
> 
> commit c98451bdb2f3e6d6cc1e03adad641e9497512b49
> Author: Frank van Maarseveen <frankvm@frankvm.com>
> Date:   Mon Jul 9 22:25:29 2007 +0200
> 
>     NLM: fix source address of callback to client
>     
>     Use the destination address of the original NLM request as the
>     source address in callbacks to the client.
>     
>     Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Silly me.  I had assumed that it had always been that way, and thus git 
would not be helpful (git's history truncates at 2.6.12).

Unfortunately Frank's patch description doesn't explain *why* this 
change was made.  I assume this fixes a bug with multi-homed servers?

> Also, other places that need to interpret rq_daddr use:
> 
> 	struct svc_sock *svsk =
> 		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
> 	switch (svsk->sk_sk->sk_family) {
> 	case AF_INET:...
>         case AF_INET6: ....
> 
> (see svcsock.c).
> 
> Why wouldn't that work here?

Should lockd be poking around in network layer data structures?  I would 
argue "no" especially because that would make lockd transport-dependent. 
  This approach wouldn't work at all for, say, RDMA transports.

What do you think of changing the rq_daddr field to be a sockaddr_storage?

--------------060608040400010904040204
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
version:2.1
end:vcard


--------------060608040400010904040204
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------060608040400010904040204
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060608040400010904040204--
