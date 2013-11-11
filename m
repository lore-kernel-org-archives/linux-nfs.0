Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48002 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753840Ab3KKTEI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Nov 2013 14:04:08 -0500
Message-ID: <52812A63.3000609@RedHat.com>
Date: Mon, 11 Nov 2013 14:05:07 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
References: <1384037221-7224-1-git-send-email-steved@redhat.com> <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com> <52811CBB.3070204@RedHat.com> <607B1346-570D-4CD6-8018-6F9C0A2B5318@netapp.com> <52812539.8030805@RedHat.com> <80321082-AFEF-48DF-A70D-6577974F8F07@netapp.com>
In-Reply-To: <80321082-AFEF-48DF-A70D-6577974F8F07@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/11/13 13:53, Myklebust, Trond wrote:
> 
> On Nov 11, 2013, at 13:43, Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 11/11/13 13:25, Myklebust, Trond wrote:
>>>
>>> On Nov 11, 2013, at 13:06, Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>>
>>>>
>>>> On 09/11/13 18:12, Myklebust, Trond wrote:
>>>>> One alternative to the above scheme, which I believe that I’ve 
>>>>> suggested before, is to have a permanent entry in rpc_pipefs 
>>>>> that rpc.gssd can open and that the kernel can use to detect 
>>>>> that it is running. If we make it /var/lib/nfs/rpc_pipefs/gssd/clnt00/gssd, 
>>>>> then AFAICS we don’t need to change nfs-utils at all, since all newer 
>>>>> versions of rpc.gssd will try to open for read anything of the form 
>>>>> /var/lib/nfs/rpc_pipefs/*/clntXX/gssd...
>>>>
>>>> After further review I am going going have to disagree with you on this.
>>>> Since all the context is cached on the initial mount the kernel
>>>
>>> What context?
>> The krb5 blob that the kernel is call up to rpc.gssd to get.. Maybe
>> I'm using the wrong terminology???
> 
> That’s only the machine cred. User credentials get allocated and freed all the time.
> 
> When the server reboots, then all GSS contexts need to be re-established, 
> which can be a lot of call_usermodehelper() upcalls; that’s one of the 
> reasons why we decided in favour of a gssd daemon in the first place.
Just curious... Why is the call_usermodehelper() upcalls more expensive
than the rpc_pipefs upcalls?

steved.

