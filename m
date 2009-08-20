From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4 referrals and migration
Date: Thu, 20 Aug 2009 17:13:17 -0400
Message-ID: <B6433F6E-C4C6-418D-8D48-53D68A9BE3D3@oracle.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-13-git-send
 -email-Trond.Myklebust@netapp.com> <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-16-git-s!
 ! ! end-email-Trond.Myklebust@netapp.com> <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-28-git-send-email-Trond.Myklebust@n
 etapp.com> <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-31-git-send-email-Trond.Myklebus!
 t@! ne! tapp.com> <74466E40-D037-4DCD-9129-0EE7B987C843@oracle!
 .com! > <1250785542.19156.12.camel@heimdal.trondhjem.org> <F9C66E65-D885-4F14-88AD-16DCC5E5B563@oracle.com> <1250795483.26904.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:61466 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754215AbZHTVOI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2009 17:14:08 -0400
In-Reply-To: <1250795483.26904.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 20, 2009, at 3:11 PM, Trond Myklebust wrote:
> On Thu, 2009-08-20 at 12:54 -0400, Chuck Lever wrote:
>>> I'm not too concerned. As it says above, this is a sample that
>>> illustrates how you could do it. It does work, though, so people can
>>> definitely use it to test the functionality.
>>
>> I'm thinking of when we want to add new upcalls, since you went to
>> some length to generalize this facility.  It would be easier to  
>> manage
>> adding a new script than it would to update an existing one, and an
>> admin or distributor could control what scripts are present, or
>> provide their own.
>>
>> The act of editing a single script is easy enough, but then you have
>> to worry about updates from the distributor possibly overwriting the
>> local modifications, and so on, and so on.
>>
>> A model like /etc/init.d might be easier to manage in the long run.
>
> True, and we might want to consider adding something like that into
> nfs-utils.
>
> Yes, I did generalise the facility: I'm planning on redoing the NFSv4
> idmapper at some point soon.

It might also work well for an in-kernel statd implementation.  The  
user script component could manage the persistent monitored host  
database, and everything else would live in the kernel.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



