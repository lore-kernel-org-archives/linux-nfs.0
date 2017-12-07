Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50426 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750779AbdLGPim (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Dec 2017 10:38:42 -0500
Subject: Re: [RFC PATCH] rpc.svcgssd: add ability to override hostname
To: Leigh Brown <leigh@solinno.co.uk>
Cc: linux-nfs@vger.kernel.org
References: <93e03b4df2fecbc505547d80935d5be7@doppler.thel33t.co.uk>
 <d3c18083-685f-9cee-73b3-7cad2fbe27c2@RedHat.com>
 <e991cf6776fa27a8c2967c19c11b0454@doppler.thel33t.co.uk>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <7cf41533-124c-b1be-e527-79fd768383d0@RedHat.com>
Date: Thu, 7 Dec 2017 10:38:40 -0500
MIME-Version: 1.0
In-Reply-To: <e991cf6776fa27a8c2967c19c11b0454@doppler.thel33t.co.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/06/2017 04:25 PM, Leigh Brown wrote:
> Hi Steve,
> 
> On 2017-11-21 17:03, Steve Dickson wrote:
>> Hello,
>>
>> On 11/20/2017 09:27 AM, Leigh Brown wrote:
>>> Add the -h option to rpc.svcgssd to allow the hostname to be overridden.
>>> This is useful in clustered configurations using NVSv4 and Kerberos to
>>> ensure the hostname is set to the service name of the cluster.
>> A couple things...
>>
>> 1) The patch did not apply for krb5_util.c or svcgssd.c. Not
>>     clear why.. but they didn't
>> 2) The patch cause a "implicit declaration of function"
>>    warning because the new routines were not added to gss_util.h
>> 3) Since the return value of gssd_sethostname() is never checked
>>    why not make it void and log an warning when something
>>    goes wrong.
>>
>> Finally, adding a command line argument is always a touchy thing,
>> supporting unnecessary flags is the last thing we want to do. So..
>> Please give me an example how this will be used, I know you say in
>> a cluster configuration, but what does that mean... A little
>> context please. Also is there any around not adding this flag
>> and achieving the same results.
>>
>> I'm not totally against adding this flag I just want to
>> investigate all avenues..
> 
> TL;DR Sorry for wasting your time, please ignore the patch.
> 
> Apologies for the delay in getting back to you.  I have been using this patch
> for the last three years on my server at home.  I have two N40L Microservers
> running Xen.  I set up an NFS cluster using NVSv4 with Kerberos authentication,
> DRBD and Pacemaker.  When I tested it back in 2015 or so, it would not fail over
> cleanly when I mounted the NFS mount on the service NFS name.  After messing
> around with setting the hostname in /etc/init.d/nfs-kernel-server  I eventually
> came up with the patch to rpc.svcgssd and it fixed the issue.
> 
> Fast forward to 2017, and I thought I might be a good idea to send this patch
> for other people to use.  Anyway, when I got your email I thought I had better
> create a couple of test VMs, set them up like my working setup and show how
> things don't work at first without the patch and then show how they work with
> the patch......except it worked perfectly.
> 
> This is quite embarrassing, actually.  I spent a few days trying to find out
> why it now worked without success, eventually I installed the stock package on
> my normal server and it still worked (to be fair I've upgraded Debian on the VMs
> once or twice in that time) .  I'm too lazy to have done all the work for no reason
> so I'm hoping that back then there was a genuine reason why it wouldn't work
> and that in the interim something has changed somewhere that fixes the issue.
> 
> Anyway, thanks very much for the feedback and sorry for wasting your time.
> 
Not a problem... Thank you for the explanation... 

steved.

