From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Fri, 5 Sep 2008 16:36:46 -0400
Message-ID: <04854041-E23D-48B5-B9FF-0B7ECEB2C371@oracle.com>
References: <20080905191939.GG22796@merfinllc.com> <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com> <20080905200455.GH22796@merfinllc.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	LKML Kernel <linux-kernel@vger.kernel.org>
To: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:31617 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbYIEUlc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 16:41:32 -0400
In-Reply-To: <20080905200455.GH22796-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 5, 2008, at Sep 5, 2008, 4:04 PM, Aaron Straus wrote:
> Hi,
>
> On Sep 05 03:56 PM, Chuck Lever wrote:
>> [ replacing cc: nfs-qX0GgiIySws@public.gmane.org with linux-nfs@vger.kernel.org, and neil's
>> old address with his current one ]
>
> Sorry I probably grabbed an old MAINTAINERS file.
>
>> On Sep 5, 2008, at Sep 5, 2008, 3:19 PM, Aaron Straus wrote:
>>> Writer_Version     Outcome:
>>> <= 2.6.19          OK
>>>> = 2.6.20	    BAD
>>
>> Up to which kernel?  Recent ones may address this issue already.
>
> BAD up to 2.6.27-rc?
>
> I have to see exactly which is the last rc version I tested.
>
>>> I can try to bisect between 2.6.19 <-> 2.6.20.
>>
>> That's a good start.
>
> OK will try to bisect.
>
>> Comparing a wire trace with strace output, starting with the writing
>> client, might also be illuminating.  We prefer wireshark as it uses
>> good default trace settings, parses the wire bytes and displays them
>> coherently, and allows you to sort the frames in various useful ways.
>
> OK.  Could you also try to reproduce on your side using those python
> programs?  I want to make sure it's not something specific with our
> mounts, etc.

I have the latest Fedora 9 kernels on two clients, mounting via NFSv3  
using "actimeo=600" (for other reasons).  The server is OpenSolaris  
2008.5.

reader.py reported zeroes in the test file after about 5 minutes.

Looking at the file a little later, I don't see any problems with it.

Since your scripts are not using any kind of serialization (ie file  
locking) between the clients, I wonder if non-determinant behavior is  
to be expected.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
