From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: libtirpc and nis
Date: Wed, 3 Jun 2009 19:59:09 -0400
Message-ID: <047CD688-878B-4504-BD59-3C0B65C1B631@oracle.com>
References: <200906031002.38551.vapier@gentoo.org> <4A269364.2080304@RedHat.com> <200906031844.34398.vapier@gentoo.org>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:65139 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbZFDAAr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2009 20:00:47 -0400
In-Reply-To: <200906031844.34398.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 3, 2009, at 6:44 PM, Mike Frysinger wrote:

> On Wednesday 03 June 2009 11:14:44 Steve Dickson wrote:
>> Mike Frysinger wrote:
>>> the libtirpc package is self described as a "standalone package".  i
>>> wonder how far that actually goes.  wrt NIS, it requires the  
>>> system C
>>> library to provide NIS functionality or you get a build failure in  
>>> a few
>>> files.  would be nice if libtirpc were usable without any NIS  
>>> baggage at
>>> all.
>>
>> NIS used RPC procedures to communicate. As it stands today
>> NIS is currently using the RPC procedures glibc. In the
>> future there is a very good chance that NIS will start
>> using the RPC procedures in libtirpc especially if
>> IPV6 support is needed...
>>
>> So I'm a bit confused on what you mean by "NIS baggage"
>> in the libtirpc package.
>
> you cannot build libtirpc on a system that doesnt provide NIS  
> functionality.
> realistic RPC usage today is NFS related services only (i.e. a NFS  
> client
> mounting a share on a NFS server).

Mike, it would help if you could provide the build output so we can  
see exactly what's failing.

> i might be missing something (since i'm no
> RPC/NIS expert), but if this scenario doesnt require NIS in any way,  
> then
> having libtirpc require/use it is bloat that should have an option  
> to disable.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
