Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503Ab2CPT06 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Mar 2012 15:26:58 -0400
Message-ID: <1331926004.2336.6.camel@localhost>
Subject: Re: Error: state manager encountered RPCSEC_GSS session expired
 against NFSv4 server
From: Sachin Prabhu <sprabhu@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 16 Mar 2012 19:26:44 +0000
In-Reply-To: <1331924613.12136.1.camel@lade.trondhjem.org>
References: <1331912791.2336.3.camel@localhost>
	 <1331919386.2518.44.camel@lade.trondhjem.org>
	 <4F637B68.2000202@fifthhorseman.net>
	 <1331924613.12136.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-03-16 at 19:03 +0000, Myklebust, Trond wrote:
> On Fri, 2012-03-16 at 13:42 -0400, Daniel Kahn Gillmor wrote:
> > On 03/16/2012 01:36 PM, Myklebust, Trond wrote:
> > > The problem is that if the client doesn't have a machine cred, then you
> > > end up taking a random user credential that may not currently be holding
> > > any OPEN files. In that case too the RENEW will fail.
> > 
> > So if i'm understanding this right:
> > 
> > Sachin's proposal fails when the machine has no machine creds.
> > 
> > The current implementation fails when the logged-in user's credentials 
> > are expired.
> > 
> > Can the NFS client's logic test for those different cases, use the 
> > appropriate creds for RENEW in their difference, and reduce the failure 
> > case to their intersection?
> 
> Simpler solution: add the call to get machine creds to the existing
> get_renew_creds function.

Hello Trond, 

I've sent a patch to the Mailing list using your suggestion above. 

Thanks
Sachin Prabhu

