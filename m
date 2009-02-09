Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:27069 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbZBISWr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 13:22:47 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Greg Banks <gnb@melbourne.sgi.com>
Message-Id: <10FF3D1C-A2A0-4354-8999-40D47957D9F3@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: howard chen <howachen@gmail.com>
In-Reply-To: <498FB7BA.6020402@melbourne.sgi.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [NFS] Advise on NFS performance tunning.
Date: Mon, 9 Feb 2009 13:22:34 -0500
References: <b66ddc900902082040m24aef720ybab2fd6646377246@mail.gmail.com> <498FB7BA.6020402@melbourne.sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 8, 2009, at 11:57 PM, Greg Banks wrote:

> howard chen wrote:
>> Are there any way I can tune my NFS setup?
>>
>> e.g.
>>
>> 1. adding more memory to server?
>> 2. adding more memory to client?
>> 3. upgrade to NFS v4?
>> ...
>>
>> NFS mount option:
>> async
>> ,noatime,noexec,nosuid,hard,intr,udp,retry=3,rsize=32768,wsize=32768
>> NFS version: 3
>>
>>
> http://mirror.linux.org.au/pub/linux.conf.au/2008/slides/130-lca2008-nfs-tuning-secrets-d7.odp
>
> See in particular slides 27-30, 71-74, 86-88.
>
> You mention increasing the server's RAM; this might help if you're
> thrashing the server's dentry or pages caches.  Unfortunately I don't
> know of a sensible or easy way to check this, except by comparing the
> working set size to RAM.
>
> Bumping up actimeo on the client could be a useful way to reduce the
> amount of GETATTR traffic.

I wonder if the GETATTR/ACCESS traffic is due to the web server  
calling open(3) on each file it serves.  Each open(3) will result in  
at least one synchronous NFS request.

You can use the "nocto" mount option plus a short "acreg{min,max}="  
setting to mitigate this.  Set acreg{min,max} to a number which  
reflects your tolerance for the web server detecting changed files on  
the NFS server (could be a minute or more).

This assumes you have only web server _read_ traffic on this mount  
point.

If the GETATTR/ACCESS traffic drops so much that the majority of your  
NFS traffic becomes READ requests, you can switch to NFS over TCP and  
use a large rsize to improve the efficiency of the READ operations.   
Increasing the client's RAM will also allow it to cache more web page  
file data, but that may not help if your web files are changing often  
(in which case Greg's server-side suggestions would be beneficial).

Naturally you should test such changes thoroughly before deploying them.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
