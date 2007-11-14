From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Use of delayed request information in nlmsvc_lookup_host
Date: Wed, 14 Nov 2007 14:00:25 -0500
Message-ID: <473B45C9.4060708@oracle.com>
References: <473B3D0B.3060204@oracle.com>
	<1195065798.7584.37.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010205050407020103010903"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsNVQ-0005nO-VI
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 11:02:33 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsNVV-000681-HT
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 11:02:38 -0800
In-Reply-To: <1195065798.7584.37.camel@heimdal.trondhjem.org>
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
--------------010205050407020103010903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Wed, 2007-11-14 at 13:23 -0500, Chuck Lever wrote:
>> Hi-
>>
>> Historical question here.
>>
>> nlmsvc_lookup_host() has this:
>>
>> struct nlm_host *
>> nlmsvc_lookup_host(struct svc_rqst *rqstp,
>>                          const char *hostname, unsigned int hostname_len)
>> {
>>          struct sockaddr_in ssin = {0};
>>
>>  >>>     ssin.sin_addr = rqstp->rq_daddr.addr;
>>          return nlm_lookup_host(1, svc_addr_in(rqstp),
>>                                 rqstp->rq_prot, rqstp->rq_vers,
>>                                 hostname, hostname_len, &ssin);
>> }
>>
>> Why is it using rq_daddr to construct the lookup target?
>>
>> The problem here is that rq_daddr isn't a full address.  It doesn't have 
>> address family information.  So nlmsvc_lookup_host() just assumes that 
>> what's stored in rq_daddr is always AF_INET.
> 
> Why can't rq_daddr hold address family information? AFAICS there is
> nothing stopping you from setting that in svc_recvfrom() and in
> svc_udp_get_dest_address().

That's correct.  I'm just trying to understand why, historically, 
rq_daddr was just the 32-bit address and not a full sockaddr to begin 
with.  There may be something we're missing, like "we didn't want to add 
another large field to this structure due to memory alignment or 
allocation efficiency concerns".  :-)

> In fact, why isn't rq_daddr defined to be a sockaddr_storage so that it
> can be safely cast into either a sockaddr_in or a sockaddr_in6 after
> checking the ss_family field?

That isn't unreasonable, but see above.

Note also we have the same problem with NLM_REBOOT (see 
nlmsvc_decode_reboot() and nlmsvc_proc_sm_notify()).  These pass and 
store a 32-bit network-endian address rather than constructing a full 
sockaddr.  A similar solution invites itself.

--------------010205050407020103010903
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


--------------010205050407020103010903
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------010205050407020103010903
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010205050407020103010903--
