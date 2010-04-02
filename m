Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:3740 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755851Ab0DBRWV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Apr 2010 13:22:21 -0400
From: Roland Dreier <rdreier@cisco.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Tom Tucker <tom@opengridcomputing.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma\@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH,RFC] nfsd: Make INET6 transport creation failure an informational message
References: <4BB522CF.60503@opengridcomputing.com>
	<4BB61F19.2000403@oracle.com>
Date: Fri, 02 Apr 2010 10:22:17 -0700
In-Reply-To: <4BB61F19.2000403@oracle.com> (Chuck Lever's message of "Fri, 02
	Apr 2010 12:45:13 -0400")
Message-ID: <adaljd57os6.fsf@roland-alpha.cisco.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

 > > The write_ports code will fail both the INET4 and INET6 transport
 > > creation if
 > > the transport returns an error when PF_INET6 is specified. Some transports
 > > that do not support INET6 return an error other than EAFNOSUPPORT.
 > 
 > That's the real bug.  Any reason the RDMA RPC transport can't return
 > EAFNOSUPPORT in this case?

I think Tom's changelog is misleading.  The problem is that the RDMA
transport actually does support IPv6, but it doesn't support the
IPV6ONLY option yet.  So if NFS/RDMA binds to a port for IPv4, then the
IPv6 bind fails because of the port collision.

Implementing the IPV6ONLY option for RDMA binding is probably not
feasible for 2.6.34, so the best band-aid for now seems to be Tom's
patch.

 - R.
-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
