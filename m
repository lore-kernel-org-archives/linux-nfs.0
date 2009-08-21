From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 17:15:45 -0400
Message-ID: <1250889345.5700.11.camel@heimdal.trondhjem.org>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org>
	 <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com>
	 <20090821182418.GE21043@fieldses.org>
	 <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
	 <20090821200403.GA23529@fieldses.org>
	 <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28905 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932584AbZHUVPr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 17:15:47 -0400
In-Reply-To: <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 16:36 -0400, Chuck Lever wrote:
> On Aug 21, 2009, at 4:04 PM, J. Bruce Fields wrote:
> > Also, while I hope this is the last bug in the mountd's flavor list
> > return, it isn't the first--only recently did we even start using real
> > information from the export instead of just faking something up.  So I
> > think it's safest to preserve the historical sec= behavior and give
> > users a way to override the negotiation, to cut down on bug reports of
> > mount failures on upgrade.
> 
> OK, if this is a recently introduced server problem, then why do we  
> need to adjust client-side behavior?  Trond's response in cases like  
> this is usually "fix the d*mn server," which you've already done.

What is the definition of "recently introduced" here? What is the exact
commit that introduced the bug in nfs-utils?

The problem is that we're changing the client, and if it turns out that
every damned Linux server that was installed out there in the past 2
years displays this bug, then Linus will call 'regression' on us and
revert the code.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
