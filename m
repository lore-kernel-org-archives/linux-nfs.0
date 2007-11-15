From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Use of delayed request information in nlmsvc_lookup_host
Date: Thu, 15 Nov 2007 12:23:46 -0500
Message-ID: <473C80A2.1020204@oracle.com>
References: <473B3D0B.3060204@oracle.com>	
	<1195065798.7584.37.camel@heimdal.trondhjem.org>	
	<473B45C9.4060708@oracle.com>	
	<1195069262.7584.54.camel@heimdal.trondhjem.org>	
	<473B5278.7090408@oracle.com>
	<18235.41907.383911.722103@notabene.brown>	
	<473C4FE2.1090402@oracle.com>
	<1195142050.7506.13.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090001040307020801060507"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsiTl-00056r-P4
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 09:26:14 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsiTk-0004MB-Lv
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 09:26:14 -0800
In-Reply-To: <1195142050.7506.13.camel@heimdal.trondhjem.org>
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
--------------090001040307020801060507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Thu, 2007-11-15 at 08:55 -0500, Chuck Lever wrote:
> 
>> What do you think of changing the rq_daddr field to be a sockaddr_storage?
> 
> Why? You've already got rq_addr.

OK, here's what I've ended up with.  I think this is what you and Neil 
have been suggesting.  Comments?

/*
  * Find an NLM client handle in the cache. If there is none, create it.
  *
  * Manufacture a specific source address in case we're using multiple
  * IP addresses on a single NIC.  NB: the family of the address in
  * rq_daddr is guaranteed to be the same as the family of rq_addr.
  */
struct nlm_host *
nlmsvc_lookup_host(struct svc_rqst *rqstp,
			const char *hostname, unsigned int hostname_len)
{
	struct sockaddr_in6 source = {
		.sin6_family	= AF_INET6,
	};

	switch(svc_addr(rqstp)->sa_family) {
	case AF_INET: {
		struct sockaddr_in *sin = (struct sockaddr_in *)&source;
		sin->sin_family = AF_INET;
		sin->sin_addr.s_addr = rqstp->rq_daddr.addr.s_addr;
		break;
	}
	case AF_INET6:
		ipv6_addr_copy(&source.sin6_addr,
                                &rqstp->rq_daddr.addr6);
		break;
	}

	return nlm_lookup_host(1, svc_addr_in(rqstp),
			       rqstp->rq_prot, rqstp->rq_vers,
			       hostname, hostname_len,
			       (struct sockaddr *)&source);
}

--------------090001040307020801060507
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


--------------090001040307020801060507
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------090001040307020801060507
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090001040307020801060507--
