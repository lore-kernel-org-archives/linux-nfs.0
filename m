From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/4] Support parsing multiple security flavors
Date: Tue, 24 Jun 2008 16:51:01 -0400
Message-ID: <1214340661.7156.54.camel@localhost>
References: <20080624202913.3366.44867.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40203 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752081AbYFXUvE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jun 2008 16:51:04 -0400
In-Reply-To: <20080624202913.3366.44867.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-06-24 at 16:33 -0400, Chuck Lever wrote:
> Hi Trond-
> 
> The following four patches implement support in the NFS client's mount option
> parser for multiple security flavors via "sec=flavor:flavor:flavor:..."  This
> replicates similar support in the legacy (non text-based) mount.nfs command.
> 
> Since the NFS client itself doesn't support multiple security flavors at the
> moment, these have been build-tested only.
> 
> Please consider them for 2.6.27.

Are you planning to add support for security negotiation or multiple
security flavours in time for 2.6.27? If not, I suggest we delay this
until such functionality exists.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
