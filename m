Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752928AbcD2PuS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 11:50:18 -0400
Subject: Re: [PATCH Version 3 0/2] Add multihostname support for NFSv4.1,2
To: Chuck Lever <chuck.lever@oracle.com>
References: <1461771407-16423-1-git-send-email-andros@netapp.com>
 <57236BB6.50103@RedHat.com> <1461940027554.14958@netapp.com>
 <572373BE.4000201@RedHat.com>
 <986CAF0C-495D-4085-A078-6B6A65CCB686@oracle.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <572382B3.3070606@RedHat.com>
Date: Fri, 29 Apr 2016 11:50:11 -0400
MIME-Version: 1.0
In-Reply-To: <986CAF0C-495D-4085-A078-6B6A65CCB686@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 29/04/16 11:24, Chuck Lever wrote:
> 
>> On Apr 29, 2016, at 10:46 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>
>>
>> On 04/29/2016 10:27 AM, Adamson, Andy wrote:
>>> Hi Steve
>>>
>>> Yes, if we decide to keep the multiple hostname option, then a man page update is required. I don't think we have a consensus on using the multiple hostname mount option as a CLI to express session trunking addresses. Chuck Lever made some good points around not using multiple hostnames:
>>>
>>> ---- From Chuck: ----
>>> - client admins can specify arbitrary hostnames on the command line; hostnames
>>> for instance that correspond to some other server.
>>>
>>> - network conditions can change at anytime, making
>>> the original set of trunks lop-sided, or some trunks
>>> may become unreachable. What if the server reboots
>>> with new i/f's or with one or more removed? The
>>> client would likely have to remount in these cases
>>> to adapt to network configuration changes.
>>>
>>> - multiple hostnames could be nailed into
>>> /etc/fstab on potentially hundreds of clients. When
>>> server or network configuration changes, there would
>>> have to be a manual change on all these clients.
>>> ----------
>>>
>>> What do you think? Should we keep the multiple hostname CLI as one method of expressing session trunking addresses?
>> I would think so...
> 
> I don't believe a mount CLI is an obvious good choice.
> 
> The client and server should provide some indication
> to each other that session trunking is supported. The
> server should provide the proper configuration
> parameters, which can change even while a client has
> mounted the server.
> 
> That's why I favor having the client perform a
> GETATTR(fs_locations) on the server's pseudofs, via
> which the server provides the correct addresses to
> use. The client can poll for changes in the address
> list on a regular basis.
> 
> Please, let's automate this instead of having to
> nail one more wonky feature into the mount CLI?
I guess I'm indifferent either way... but automation
is always a good thing... 

steved.
 
