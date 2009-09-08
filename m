From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] support "-t nfs -o vers=4" [take 3]
Date: Tue, 8 Sep 2009 17:18:28 -0400
Message-ID: <0922B0F5-8097-49FB-9624-00B260B181B6@oracle.com>
References: <20090908210012.3326.57767.stgit@matisse.1015granger.net> <4AA6C89F.1030801@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:40717 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbZIHVSp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 17:18:45 -0400
In-Reply-To: <4AA6C89F.1030801-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 8, 2009, at 5:11 PM, Steve Dickson wrote:
> On 09/08/2009 05:02 PM, Chuck Lever wrote:
>> Hi Steve-
>>
>> These changes accompany kernel support for "-t nfs -o vers=4".
>>
>> One patch description was clarified, and a bug was fixed in the last
>> patch of this series.
>>
> I'm a bit concern about committing these since its not clear which
> kernel the supporting patches will be in... Why document something
> that does not work...

If Trond doesn't accept the kernel patches, you can trash bin these.   
Otherwise there's no need to do anything until we know how "vers=4"  
will be supported.

But I wanted to be sure you had the version of this series with the  
bug fix.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



