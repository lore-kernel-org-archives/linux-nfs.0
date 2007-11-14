From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Use of delayed request information in nlmsvc_lookup_host
Date: Wed, 14 Nov 2007 14:32:51 -0500
Message-ID: <20071114193251.GM14254@fieldses.org>
References: <473B3D0B.3060204@oracle.com>
	<1195065798.7584.37.camel@heimdal.trondhjem.org>
	<473B45C9.4060708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsNz8-0000XM-2R
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 11:33:14 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsNzC-0007ih-Ka
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 11:33:20 -0800
In-Reply-To: <473B45C9.4060708@oracle.com>
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

On Wed, Nov 14, 2007 at 02:00:25PM -0500, Chuck Lever wrote:
> Trond Myklebust wrote:
>> On Wed, 2007-11-14 at 13:23 -0500, Chuck Lever wrote:
>>> Hi-
>>>
>>> Historical question here.
>>>
>>> nlmsvc_lookup_host() has this:
>>>
>>> struct nlm_host *
>>> nlmsvc_lookup_host(struct svc_rqst *rqstp,
>>>                          const char *hostname, unsigned int hostname_len)
>>> {
>>>          struct sockaddr_in ssin = {0};
>>>
>>>  >>>     ssin.sin_addr = rqstp->rq_daddr.addr;
>>>          return nlm_lookup_host(1, svc_addr_in(rqstp),
>>>                                 rqstp->rq_prot, rqstp->rq_vers,
>>>                                 hostname, hostname_len, &ssin);
>>> }
>>>
>>> Why is it using rq_daddr to construct the lookup target?
>>>
>>> The problem here is that rq_daddr isn't a full address.  It doesn't have 
>>> address family information.  So nlmsvc_lookup_host() just assumes that 
>>> what's stored in rq_daddr is always AF_INET.
>>
>> Why can't rq_daddr hold address family information? AFAICS there is
>> nothing stopping you from setting that in svc_recvfrom() and in
>> svc_udp_get_dest_address().
>
> That's correct.  I'm just trying to understand why, historically, rq_daddr 
> was just the 32-bit address and not a full sockaddr to begin with.  There 
> may be something we're missing, like "we didn't want to add another large 
> field to this structure due to memory alignment or allocation efficiency 
> concerns".  :-)

Maybe somebody should be thinking about it, but I don't think anyone
has.  And if they did, this would seem the wrong place to skimp.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
