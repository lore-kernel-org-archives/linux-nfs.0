Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46331 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbaFMKo6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jun 2014 06:44:58 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so2003702pad.20
        for <linux-nfs@vger.kernel.org>; Fri, 13 Jun 2014 03:44:57 -0700 (PDT)
Message-ID: <539AD609.4040205@gmail.com>
Date: Fri, 13 Jun 2014 18:44:25 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: Re: [PATCH v2] NFS4.1: try to clean sessions after testing
References: <5396D7FA.4050303@gmail.com> <5396F243.8080606@gmail.com> <20140611211742.GH19382@fieldses.org> <5398E544.9000105@gmail.com> <53990498.7020300@gmail.com> <20140612152528.GD5437@fieldses.org>
In-Reply-To: <20140612152528.GD5437@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/12/2014 23:25, J. Bruce Fields wrote:
> On Thu, Jun 12, 2014 at 09:38:32AM +0800, Kinglong Mee wrote:
>> On 6/12/2014 07:24, Kinglong Mee wrote:
>>> On 6/12/2014 05:17, J. Bruce Fields wrote:
>>>> I tried to apply this, and the ipv6 patch (could we do that for 4.1
>>>> too?) and the 3 other patches, but:
>>>
>>> nfs4.1 has supports IPv6, the patch for nfs4.0 is a back-port from nfs4.1.
> 
> OK, thanks for explaining.
> 
>>>
>>>>
>>>> 	- there are some conflicts with the latest pynfs (e.g. I already
>>>> 	  added a few acl tests, apologies)
>>>> 	- I'm getting failures to write to a read-only fs, apparently
>>>> 	  one of the tests is trying to write to the export root?  I
>>>> 	  didn't check which one.
>>
>> Can you show me more information about this?
> 
> [root@pip5 pynfs]# ./nfs4.0/testserver.py f19:/exports/xfs/pynfstest-user --maketree
> Initialization failed, no tests run.
> Traceback (most recent call last):
>   File "./nfs4.0/testserver.py", line 381, in <module>
>     main()
>   File "./nfs4.0/testserver.py", line 344, in main
>     env.init()
>   File "/root/pynfs/nfs4.0/servertests/environment.py", line 140, in init
>     self._maketree()
>   File "/root/pynfs/nfs4.0/servertests/environment.py", line 162, in _maketree
>     check(res, msg="Trying to create /%s," % '/'.join(path))
>   File "/root/pynfs/nfs4.0/servertests/environment.py", line 253, in check
>     raise testmod.FailureException(msg)
> testmod.FailureException: Trying to create /tmp, should return NFS4_OK, instead got NFS4ERR_ROFS
> 
> This happens after the ipv6 patch.
> 
> Note /exports on my server is exported read-only, xfs is a separate writeable
> filesystem.

Thanks for your testing.
I have found this bug in IPv6 path, and will send three new path all I have.

thanks,
Kinglong Mee
