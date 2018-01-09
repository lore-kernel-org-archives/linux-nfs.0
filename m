Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fw.vincze.org ([71.184.222.21]:56975 "EHLO mailgw.vincze.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756477AbeAIUrw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Jan 2018 15:47:52 -0500
Subject: Re: Varying ro/rw based on security flavor doesn't work
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <890d00b1-fb64-1011-4a44-2e47713de0f7@vincze.org>
 <20180109192338.GC18087@fieldses.org>
From: Tamas Vincze <tom@vincze.org>
Message-ID: <83d5cd2e-d295-8d1c-85a0-bdc328307d6a@vincze.org>
Date: Tue, 9 Jan 2018 15:47:50 -0500
MIME-Version: 1.0
In-Reply-To: <20180109192338.GC18087@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/09/2018 02:23 PM, J. Bruce Fields wrote:
> On Tue, Jan 09, 2018 at 10:11:05AM -0500, Tamas Vincze wrote:
>> The exports man page says that one can vary ro/rw based on security
>> flavor by including multiple sec= options in /etc/exports, but it
>> seems to be broken in nfs-utils-1.3.0-0.48.el7_4.
>>
>> For example this /etc/exports:
>>
>> /export/pub 10.13.0.0/16(sec=sys,ro,sec=krb5i:krb5p,rw)
>>
>> results in this /var/lib/nfs/etab:
>>
>> /export/pub 10.13.0.0/16(rw,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,no_subtree_check,secure_locks,acl,no_pnfs,anonuid=65534,anongid=65534,sec=sys,secure,root_squash,no_all_squash,sec=krb5i:krb5p,secure,root_squash,no_all_squash)
>>
>> Only the rw option is present in etab, that applies to both sec=sys
>> and sec=krb5i:krb5p.
>>
>> Is this bug specific to redhat or also present upstream?
> I don't know off the top of my head....  Is there a redhat bug filed?
I filed one today: https://bugzilla.redhat.com/show_bug.cgi?id=1532688
It has no duplicates so far...
> And is there some prevoius version that you know worked?
I don't know, I haven't used this feature before.
> Agreed that it looks like a bug.
>
> --b.
And it can have some security implications if people have been relying 
on it and it quietly broke (sec=sys is basically no security these 
days). I see this feature has been around for more than a decade so 
there's a good chance that it's in use.

-Tamas
