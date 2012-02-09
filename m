Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e33.co.us.ibm.com ([32.97.110.151]:55755 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab2BIOtt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2012 09:49:49 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 9 Feb 2012 07:49:47 -0700
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 16AA2C90058
	for <linux-nfs@vger.kernel.org>; Thu,  9 Feb 2012 09:48:47 -0500 (EST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q19EmdgY2146468
	for <linux-nfs@vger.kernel.org>; Thu, 9 Feb 2012 09:48:40 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q19EmE8j015254
	for <linux-nfs@vger.kernel.org>; Thu, 9 Feb 2012 07:48:14 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q19EmDoJ015206
	for <linux-nfs@vger.kernel.org>; Thu, 9 Feb 2012 07:48:14 -0700
Date: Thu, 9 Feb 2012 08:48:13 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS Mount Option 'nofsc'
Message-ID: <20120209144812.GA15569@us.ibm.com>
References: <4F31E1CA.8060105@ti.com>
 <1328676860.2954.9.camel@lade.trondhjem.org>
 <1328687026.8981.25.camel@serendib>
 <386479B9-C285-44C9-896B-A254091272FD@oracle.com>
 <1328759776.8981.75.camel@serendib>
 <1328760721.3234.86.camel@lade.trondhjem.org>
 <1328766702.8981.106.camel@serendib>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1328766702.8981.106.camel@serendib>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Harshula [harshula@redhat.com] wrote:
> Hi Trond,
> 
> Thanks for the reply. Could you please elaborate on the subtleties
> involved that require an application to be rewritten if forcedirectio
> mount option was available?
> 
> On Thu, 2012-02-09 at 04:12 +0000, Myklebust, Trond wrote:
> > On Thu, 2012-02-09 at 14:56 +1100, Harshula wrote:
> > >
> > > The "sync" option, depending on the NFS server, may impact the NFS
> > > server's performance when serving many NFS clients. But still worth a
> > > try.
> > 
> > What on earth makes you think that directio would be any different?
> 
> Like I said, sync is still worth a try. I will do O_DIRECT Vs sync mount
> option runs and see what the numbers look like. A while back the numbers
> for cached Vs direct small random writes showed as the number of threads
> increased the cached performance fell well below direct performance. In
> this case I'll be looking at large streaming writes, so completely
> different scenario, but I'd like to verify the numbers first.

directio and sync behavior should be same on server side, but it would
be a different story on the client though. The above behavior you
described is expected on the client.

Thanks, Malahal.

