Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:49140 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756031Ab3DWPve convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Apr 2013 11:51:34 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Simo Sorce <simo@redhat.com>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Interoperable junctions on Linux
Date: Tue, 23 Apr 2013 15:51:31 +0000
Message-ID: <1366732290.35524.13.camel@leira.trondhjem.org>
References: <71999CA2-F6E7-4DE1-9DC3-AED77626DE7F@oracle.com>
	 <1366728674.7239.63.camel@willson.li.ssimo.org>
	 <BDD9FCE5-E573-4E01-A5D9-A8A3811895DD@oracle.com>
In-Reply-To: <BDD9FCE5-E573-4E01-A5D9-A8A3811895DD@oracle.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-23 at 11:42 -0400, Chuck Lever wrote:
> On Apr 23, 2013, at 10:51 AM, Simo Sorce <simo@redhat.com> wrote:

> > Also why a xattr in the trusted namespace ? What are the security
> > considerations that warrants a trusted attribute rather than a normal
> > one ? (Links to RFCs or other docs are just fine)
> 
> This is another historical design decision.  If there is consensus that we don't need to protect junction metadata from unintended or malicious local changes, then we can put these in another namespace.  However, without strong security here, redirecting network clients to another server and export can be hijacked, sending remote users to who knows where.  Is it enough simply to insist that junctions be owned by root?

Junctions resolve into mountpoints on clients. Allowing arbitrary users
to change the junction parameters basically means giving them the
ability to control the namespace on clients. They can for instance
redirect an application from a trusted server onto an untrusted one.

I therefore strongly recommend that we ensure the creation, deletion and
modification of a junction remains a privileged operation on the server.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
