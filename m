Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from extranet.sessys.com ([50.116.54.220]:60930 "EHLO
	extranet.sessys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbbFHQtZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 12:49:25 -0400
To: Chuck Lever <chucklever@gmail.com>
Subject: Re: [PATCH] rpc.nfsd: add no-ipv4 and no-ipv6 options
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Mon, 08 Jun 2015 12:49:23 -0400
From: Sean Elble <elbles@sessys.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org
In-Reply-To: <AA024850-47EF-40EB-A312-D2490D6FCEC5@gmail.com>
References: <55743EDE.7070707@gmail.com>
 <3CE6594A-508B-4BBD-9E52-CF9EDDA6274D@oracle.com>
 <557597D3.8090401@gmail.com>
 <312511264c19c5a98cbd1062531b306e@mail.sessys.com>
 <2F03891D-9240-4A8E-BEEB-7F5BBAD1B5FE@gmail.com>
 <76DB6DF0-8409-4D42-B2FD-6C7B08B148A5@gmail.com>
 <d4bfa4c82f2a8ef2dec4dce303c0c96b@mail.sessys.com>
 <AA024850-47EF-40EB-A312-D2490D6FCEC5@gmail.com>
Message-ID: <7317134dfd069e17171db7e004baa2c6@mail.sessys.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08.06.2015 10:45, Chuck Lever wrote:
> On Jun 8, 2015, at 10:33 AM, Sean Elble <elbles@sessys.com> wrote:
> 
>> On 08.06.2015 10:27, Chuck Lever wrote:
>>>> I don’t understand the need to “turn off” an address family. 
>>>> That’s what
>>>> /etc/netconfig is supposed to be for. What’s not happening here 
>>>> that
>>>> should be?
>>> What I mean is: I’d rather not add more command line options if 
>>> there
>>> is a way for rpc.nfsd to automatically and quietly do what is needed.
>>> But I don’t understand the use case here. Sean, can you explain it 
>>> for
>>> bears of little brain?
>> 
>> Sure, and please correct me if any of my understanding is incorrect 
>> (as it may well be).  In my environment, I wanted to have NFS only 
>> listen on one interface of a multihomed host.  In using the "--host" 
>> parameter to do so, I saw the error message regarding IPv6 thrown.
> 
> OK, yes I read that last week, and had just forgotten it. That sounds 
> to
> me like - - host is broken (or, at least noisier than it should be in 
> this
> case).

Agreed.  I guess it's just a matter of what the appropriate fix is.

> 
> Do you provide an IP address or a hostname when specifying - - host?

I've provided both hostname and IP address, with the same result, IIRC.

> 
>> While disabling IPv6 globally in /etc/netconfig is an option (one I 
>> understand to be "global", in that it'd affect *all* applications on 
>> the host), it'd be nice to disable IPv6 for a single service/daemon 
>> instead.
>> 
>> Of course, the fact that at least Ubuntu and RHEL (and almost 
>> certainly their upstream and their derivatives, respectively) relay 
>> the error message when running the NFS init scripts could confuse 
>> someone into thinking NFS failed to start properly (until they look at 
>> the output of netstat -nalp, etc.).  I'd almost argue that's a larger 
>> concern. By the same token, "--host" seems a little used option, for 
>> whatever reason.
>> 
>> In any case, I'm the little brained one in this group.  :-)
> 
> --
> Chuck Lever
> chucklever@gmail.com
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
