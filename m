From: Steve Dickson <SteveD@redhat.com>
Subject: Re: libtirpc and nis
Date: Thu, 04 Jun 2009 10:15:27 -0400
Message-ID: <4A27D6FF.9070702@RedHat.com>
References: <200906031002.38551.vapier@gentoo.org>	 <200906031844.34398.vapier@gentoo.org>	 <047CD688-878B-4504-BD59-3C0B65C1B631@oracle.com>	 <200906032012.21876.vapier@gentoo.org>  <4A279C05.9030108@RedHat.com> <1244117219.5203.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mike Frysinger <vapier@gentoo.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49356 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753912AbZFDOSs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2009 10:18:48 -0400
In-Reply-To: <1244117219.5203.12.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust wrote:
> On Thu, 2009-06-04 at 06:03 -0400, Steve Dickson wrote:
>> Mike Frysinger wrote:
>>> On Wednesday 03 June 2009 19:59:09 Chuck Lever wrote:
>>>> On Jun 3, 2009, at 6:44 PM, Mike Frysinger wrote:
>>>>> On Wednesday 03 June 2009 11:14:44 Steve Dickson wrote:
>>>>>> Mike Frysinger wrote:
>>>>>>> the libtirpc package is self described as a "standalone package".  i
>>>>>>> wonder how far that actually goes.  wrt NIS, it requires the
>>>>>>> system C
>>>>>>> library to provide NIS functionality or you get a build failure in
>>>>>>> a few
>>>>>>> files.  would be nice if libtirpc were usable without any NIS
>>>>>>> baggage at
>>>>>>> all.
>>>>>> NIS used RPC procedures to communicate. As it stands today
>>>>>> NIS is currently using the RPC procedures glibc. In the
>>>>>> future there is a very good chance that NIS will start
>>>>>> using the RPC procedures in libtirpc especially if
>>>>>> IPV6 support is needed...
>>>>>>
>>>>>> So I'm a bit confused on what you mean by "NIS baggage"
>>>>>> in the libtirpc package.
>>>>> you cannot build libtirpc on a system that doesnt provide NIS
>>>>> functionality.
>>>>> realistic RPC usage today is NFS related services only (i.e. a NFS
>>>>> client
>>>>> mounting a share on a NFS server).
>>>> Mike, it would help if you could provide the build output so we can
>>>> see exactly what's failing.
>>> libtirpc does not provide rpcsvc/nis.h
>> Hmm... I wonder what it would take to incorporate that file into
>> libitrpc... 
> 
> rpcgen support. We already have the nis.x file in glibc's copy of the
> rpcsvc directory.
I'm thinking more of licensing issues..

steved.
 
