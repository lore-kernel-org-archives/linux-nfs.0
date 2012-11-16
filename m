Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36200 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599Ab2KPNjF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Nov 2012 08:39:05 -0500
Message-ID: <50A641F5.3080403@RedHat.com>
Date: Fri, 16 Nov 2012 08:39:01 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs(5): Document the minorversion= mount option
References: <20121114223600.48062.5680.stgit@seurat.1015granger.net> <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0DB4@SACEXCMBX04-PRD.hq.netapp.com> <A7E004BD-A5DA-4258-978A-80E46DBE3D32@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0E75@SACEXCMBX04-PRD.hq.netapp.com> <8CFA849C-DE85-41BB-8EEA-DBC9FF65FB6E@oracle.com>
In-Reply-To: <8CFA849C-DE85-41BB-8EEA-DBC9FF65FB6E@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

First of all, thanks for point this out... 

On 14/11/12 18:37, Chuck Lever wrote:
> 
> On Nov 14, 2012, at 6:12 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
>> On Wed, 2012-11-14 at 18:03 -0500, Chuck Lever wrote:
>>> On Nov 14, 2012, at 6:01 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>>
>>>>> -----Original Message-----
>>>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>>>>> owner@vger.kernel.org] On Behalf Of Chuck Lever
>>>>> Sent: Wednesday, November 14, 2012 5:39 PM
>>>>> To: linux-nfs@vger.kernel.org
>>>>> Subject: [PATCH] nfs(5): Document the minorversion= mount option
>>>>>
>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> ---
>>>>>
>>>>> Our pals on the Solaris team recently noticed that the minorversion= option
>>>>> is not documented in nfs(5).  This is a first take, just to start the conversation.
>>>>> I'm pretty sure I got the kernel version information wrong, for instance.
>>>>>
>>>>> Any other comments?
>>>>
>>>> You might want to note that it is deprecated in favour of the "vers=4.1" notation, and for that reason we might want to forgo documenting it altogether.
>>>
>>> OK.  minorversion= is the only way to get NFSv4.1 on EL6-based distributions, isn't it?
>>
>> You didn't seem to be writing a manpage for the RHEL-6 distros: "Before
>> kernel 2.6.38, the minor version is always zero...". As far as I know,
>> RHEL-6 is still based on 2.6.32...
2.6.32 is where we made the branch. So it accurate to say RHEL6 is based
on 2.6.36, but in reality it absolutely not a straight 2.6.32 upstream 
kernel due to all the backporting we do.  

> 
> ...for some very loose definition of "based on".  One wonders how to document kernel versions in this instance.  One way to fix this is to have RH patch their copy of nfs(5) privately, while upstream nfs-utils can handle this in some other way.
Yeah, We'll have to carry an private patch that updates the man page. 

> 
> However, search for "Parallel NFS" on this page:
> 
>   https://access.redhat.com/knowledge/docs/en-US/Red_Hat_Enterprise_Linux/6/html-single/6.2_Release_Notes/index.html
> 
> This seems to me to count as public documentation of "minorversion=", and suggests that people are likely already using this formal API.  I would hesitate to remove it in this instance.
> 
If upstream wants to deprecate minorversion= than so be it... That will have
little effect on a RHEL release since we can't change the API like that... 

steved.
