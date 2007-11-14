From: Chuck Lever <chuck.lever@oracle.com>
Subject: Use of delayed request information in nlmsvc_lookup_host
Date: Wed, 14 Nov 2007 13:23:07 -0500
Message-ID: <473B3D0B.3060204@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030506010309080101080205"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsMv7-0001rv-Vo
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 10:25:02 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsMv8-0002oQ-8F
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 10:25:02 -0800
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
--------------030506010309080101080205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi-

Historical question here.

nlmsvc_lookup_host() has this:

struct nlm_host *
nlmsvc_lookup_host(struct svc_rqst *rqstp,
                         const char *hostname, unsigned int hostname_len)
{
         struct sockaddr_in ssin = {0};

 >>>     ssin.sin_addr = rqstp->rq_daddr.addr;
         return nlm_lookup_host(1, svc_addr_in(rqstp),
                                rqstp->rq_prot, rqstp->rq_vers,
                                hostname, hostname_len, &ssin);
}

Why is it using rq_daddr to construct the lookup target?

The problem here is that rq_daddr isn't a full address.  It doesn't have 
address family information.  So nlmsvc_lookup_host() just assumes that 
what's stored in rq_daddr is always AF_INET.

As I started adding support for AF_INET6 to lockd, I noticed that 
there's no way for nlmsvc_lookup_host() to know that it should construct 
a sockaddr_in6 instead.

--------------030506010309080101080205
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


--------------030506010309080101080205
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------030506010309080101080205
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030506010309080101080205--
