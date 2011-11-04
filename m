Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:54786 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932455Ab1KDOCX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 10:02:23 -0400
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111104132050.GB13788@umich.edu>
Date: Fri, 4 Nov 2011 10:01:54 -0400
Cc: Lukas Razik <linux@razik.name>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <01668DEE-43F7-464B-9BCF-6E52DF0B5956@oracle.com>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com> <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com> <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com> <20111104132050.GB13788@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 4, 2011, at 9:20 AM, Jim Rees wrote:

> As for a fix...  we're trying to move away from udp transport anyway.  Maybe
> someone should figure out a way to get it to work with tcp?  I have zero
> experience with nfs over udp, at least on linux.  Just for fun, have you
> tried tcp transport (proto=tcp)?

TCP is a real problem in this environment, because it deals poorly with NIC initialization timing issues.  UDP is still the best approach (as long as it is retransmitting appropriately).  To support TCP, ultimately what we need to do is to introduce serialization to make the kernel wait for the NIC to become ready before attempting network activity.

> As we move toward nfs4 someone will have to give some thought to nfsroot.
> It's hard to imagine we could put enough nfs4 cruft into the kernel (gssd,
> idmapd) to make it work.

A kernel-level basic id mapper is being considered.  That would allow NFSv4 with AUTH_SYS, if we can get the NIC problems squared away.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




