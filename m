Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38912 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932550Ab1KDOZS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 10:25:18 -0400
Date: Fri, 4 Nov 2011 10:24:32 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>,
        Lukas Razik <linux@razik.name>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Message-ID: <20111104142432.GA31541@fieldses.org>
References: <20111103211100.GA8393@umich.edu>
 <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com>
 <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com>
 <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com>
 <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>
 <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
 <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>
 <20111104132050.GB13788@umich.edu>
 <01668DEE-43F7-464B-9BCF-6E52DF0B5956@oracle.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA9256@SACMVEXC2-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA9256@SACMVEXC2-PRD.hq.netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 04, 2011 at 07:09:41AM -0700, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: Chuck Lever [mailto:chuck.lever@oracle.com]
> > Sent: Friday, November 04, 2011 10:02 AM
> > To: Jim Rees
> > Cc: Lukas Razik; Myklebust, Trond; Linux NFS Mailing List
> > Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
> > 
> > 
> > On Nov 4, 2011, at 9:20 AM, Jim Rees wrote:
> > > As we move toward nfs4 someone will have to give some thought to
> > nfsroot.
> > > It's hard to imagine we could put enough nfs4 cruft into the kernel
> > > (gssd,
> > > idmapd) to make it work.
> > 
> > A kernel-level basic id mapper is being considered.  That would allow
> NFSv4
> > with AUTH_SYS, if we can get the NIC problems squared away.
> 
> We already have a solution for NFSv4 and nfsroot: use auth_sys and set
> the nfs4_disable_idmapping flag. That does require an rfc3530-bis
> compatible server, but it shouldn't be long before we see those
> appearing in the wild...

And I *do* want to get back to that, I just haven't had the time.
(Patches welcome if someone else is motivated.)

--b.
