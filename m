Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:63000 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab1KLVGg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 16:06:36 -0500
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111112184804.GA25581@umich.edu>
Date: Sat, 12 Nov 2011 16:06:17 -0500
Cc: Lukas Razik <linux@razik.name>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1E7FF4C1-B7BA-4429-92ED-DC90D6B269C4@oracle.com>
References: <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com> <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com> <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com> <1320450001.87605.YahooMailNeo@web24706.mail.ird.yahoo.com> <1320455965.2750.9.camel@lade.trondhjem.org> <1320459252.59518.YahooMailNeo@web24716.mail.ird.yahoo.com> <1320460311.2750.21.camel@lade.trondhjem.org> <1320465106.61111.YahooMailNeo@web24710.mail.ird.yahoo.com> <20111105130517.GA16090@umich.edu> <1321097734.7117.YahooMailNeo@web24701.mail.ird.yahoo.com> <20111112184804.GA25581@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2011, at 1:49 PM, Jim Rees wrote:

> The question for us is how long should an nfsroot client wait for the server
> to reply.  It sounds like the client used to wait longer than it does now.

Before, the client performed the GETPORT(NFS) step synchronously, first.  This took 30 seconds or so to timeout.  When it did, the client decided to proceed with port 2049.  Then it went on to do the other mount tasks, and at the point had waited long enough that these tasks did not time out while waiting for the switch port.

> It seems to me the client should wait at least 90 seconds so that the
> situation you're in (servers on non-portfast ports) will work.  I would
> think they should wait indefinitely, since there's not much else they can
> do.

It should be simple to wrap the (MNT(mnt), NFS(getroot)) steps in a while(true) loop.  Would mount_root_nfs() be the right place for this?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




