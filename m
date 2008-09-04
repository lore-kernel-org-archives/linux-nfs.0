From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RESTRICTED_STATD
Date: Thu, 4 Sep 2008 11:51:41 -0400
Message-ID: <0B107F2C-ED5A-4098-B59D-FF24CEA2C44B@oracle.com>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com> <48B5332B.2040800@RedHat.com> <76bd70e30808270714p4342c8c3k8d1b98763cc95aef@mail.gmail.com> <EB4BA6CC-B023-49DC-9FE6-BD478DA5CB9F@oracle.com> <3400963b9465552abb83ecefede125bc.squirrel@neil.brown.name> <EB1B1F05-65DA-4A18-80F6-13DE4FCB387C@oracle.com> <18623.31268.970805.5694@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <steved@redhat.com>, Olaf Kirch <okir@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:17722 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbYIDPwZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 11:52:25 -0400
In-Reply-To: <18623.31268.970805.5694-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

On Sep 4, 2008, at Sep 4, 2008, 2:03 AM, Neil Brown wrote:
> On Tuesday September 2, chuck.lever@oracle.com wrote:
>>> Only NOTIFY can come from other hosts (to tell us they rebooted).
>>
>> Right.  sm_notify_1_svc() grabs the callers IP address with
>>
>>    svc_getcaller(rqstp->rq_xprt)->sin_addr
>>
>> It converts this to a string and checks this against lp->dns_name, in
>> addition to checking the mon_name that was originally registered to  
>> be
>> monitored.  Shouldn't statd check only mon_name against dns_name?   
>> Why
>> does it check both?
>
> If it was to only check one, it would probably to check ip_addr
> against dns_name.
>
> The IP address of that the SM_NOTIFY came from is the most reliable
> thing we have to identify which host just rebooted.  We use that to
> find a 'dns_name' when we first MONitor a host, and use that name for
> the file stored in /var/lib/nfs/sm.  We then match the source of
> SM_NOTIFY against those file names.

Honestly, I would have thought exactly the opposite is true.  How  
would that work with multi-homed peers?  Or with peers that might get  
their IP addresses via DHCP?

AFAICT the reason why using only mon_name is sometimes broken is  
because the Linux implementation (and it is probably not alone in this  
regard) chooses a mon_name that is often not unique.

Sometimes it's simply the unqualified hostname.  If you have a  
"joe.server.example.com" and a "joe.desktop.example.com" it would be  
pretty difficult for statd to distinguish them by their unqualified  
hostnames alone.

Really lockd/sm-notify should select a mon_name with a better  
guarantee of uniqueness.  A base64 hash of one of the NICs on the  
peer, for example, would be much better.  Hash in the wall clock time  
and date, and store it in a file in /var/lib/nfs so it doesn't change  
if the NIC hardware is moved.

Is there any guidance in the Open Group standard on how to match  
SM_NOTIFY requests to SM_MON?  I had thought it was "use the mon_name,  
Luke".

> So I think this part of the code really does need to be IPv6-aware.
> Certainly matchhostname does.
>
>>> However we don't really want any user to be able to request a  
>>> callback
>>> to any random service....
>>> I wonder if anyone uses for statd for anything but lockd, and how
>>> could we know?
>>
>> I think the real question is whether we should continue to support
>> this "off-label" use.  It adds complexity and security problems, and
>> the code paths that support this aren't ever tested these days, I'm
>> willing to bet.
>
> How about we subtly break it, and then we nobody complains for 12
> months, remove it as it was broken anyway :-)

And normally I would take that approach.  In this case, folks want  
real IPv6 support yesterday...

> I'm think I'm happy with removing any support for non-lockd uses for
> statd.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
