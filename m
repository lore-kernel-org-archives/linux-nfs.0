From: Steve Dickson <SteveD@redhat.com>
Subject: Re: libtirpc and nis
Date: Thu, 04 Jun 2009 13:53:46 -0400
Message-ID: <4A280A2A.2040007@RedHat.com>
References: <200906031002.38551.vapier@gentoo.org>	 <200906031844.34398.vapier@gentoo.org>	 <047CD688-878B-4504-BD59-3C0B65C1B631@oracle.com>	 <200906032012.21876.vapier@gentoo.org>  <4A279C05.9030108@RedHat.com>	 <1244117219.5203.12.camel@heimdal.trondhjem.org>	 <4A27D6FF.9070702@RedHat.com> <1244125476.5203.21.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mike Frysinger <vapier@gentoo.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57201 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637AbZFDR47 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2009 13:56:59 -0400
In-Reply-To: <1244125476.5203.21.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust wrote:
>>>>> libtirpc does not provide rpcsvc/nis.h
>>>> Hmm... I wonder what it would take to incorporate that file into
>>>> libitrpc... 
>>> rpcgen support. We already have the nis.x file in glibc's copy of the
>>> rpcsvc directory.
>> I'm thinking more of licensing issues..
> 
> I know. I'm saying that we're already distributing it through glibc. We
> don't need to distribute it again in libtirpc; we can just make use of
> the existing .x file.
Understood... But the ultimate goal here is to completely wean ourself
from the any of the glibc RPC code... so having similar header files
in a couple places is the price we are going to have to pay... IMHO...

steved.

