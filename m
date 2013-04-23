Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756452Ab3DWQTh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 12:19:37 -0400
Subject: Re: Interoperable junctions on Linux
From: Simo Sorce <simo@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <1366732290.35524.13.camel@leira.trondhjem.org>
References: <71999CA2-F6E7-4DE1-9DC3-AED77626DE7F@oracle.com>
	 <1366728674.7239.63.camel@willson.li.ssimo.org>
	 <BDD9FCE5-E573-4E01-A5D9-A8A3811895DD@oracle.com>
	 <1366732290.35524.13.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Apr 2013 12:19:32 -0400
Message-ID: <1366733972.7239.66.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-23 at 15:51 +0000, Myklebust, Trond wrote:
> On Tue, 2013-04-23 at 11:42 -0400, Chuck Lever wrote:
> > On Apr 23, 2013, at 10:51 AM, Simo Sorce <simo@redhat.com> wrote:
> 
> > > Also why a xattr in the trusted namespace ? What are the security
> > > considerations that warrants a trusted attribute rather than a normal
> > > one ? (Links to RFCs or other docs are just fine)
> > 
> > This is another historical design decision.  If there is consensus that we don't need to protect junction metadata from unintended or malicious local changes, then we can put these in another namespace.  However, without strong security here, redirecting network clients to another server and export can be hijacked, sending remote users to who knows where.  Is it enough simply to insist that junctions be owned by root?
> 
> Junctions resolve into mountpoints on clients. Allowing arbitrary users
> to change the junction parameters basically means giving them the
> ability to control the namespace on clients. They can for instance
> redirect an application from a trusted server onto an untrusted one.
> 
> I therefore strongly recommend that we ensure the creation, deletion and
> modification of a junction remains a privileged operation on the server.

Is it not sufficient to make sure the symlink is owned by root ?

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

