Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3897 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219Ab1KDPSl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 11:18:41 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Date: Fri, 4 Nov 2011 08:18:19 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA9272@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20111104144617.GB911@umich.edu>
References: <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com> <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com> <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com> <20111104132050.GB13788@umich.edu> <01668DEE-43F7-464B-9BCF-6E52DF0B5956@oracle.com> <20111104144617.GB911@umich.edu>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Jim Rees" <rees@umich.edu>, "Chuck Lever" <chuck.lever@oracle.com>
Cc: "Lukas Razik" <linux@razik.name>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Jim Rees [mailto:rees@umich.edu]
> Sent: Friday, November 04, 2011 10:46 AM
> To: Chuck Lever
> Cc: Lukas Razik; Myklebust, Trond; Linux NFS Mailing List
> Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
> 
> Chuck Lever wrote:
> 
>   On Nov 4, 2011, at 9:20 AM, Jim Rees wrote:
>   > As we move toward nfs4 someone will have to give some thought to
> nfsroot.
>   > It's hard to imagine we could put enough nfs4 cruft into the
kernel (gssd,
>   > idmapd) to make it work.
> 
>   A kernel-level basic id mapper is being considered.  That would
allow
>   NFSv4 with AUTH_SYS, if we can get the NIC problems squared away.
> 
> Actually I wonder if you could get by with auth_sys, no gss, and no id
> mapping until you get to the point where the root is remounted by user
land.

Please read RFC3530-bis. This is a solved problem.
