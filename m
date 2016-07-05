Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59535 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751105AbcGETGc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jul 2016 15:06:32 -0400
Subject: Re: /etc/exports parsing is borked again in nfs-utils
To: Trond Myklebust <trondmy@primarydata.com>
References: <1466885520.9316.4.camel@primarydata.com>
 <151cf713-410a-b073-5c5a-430691fb5e6d@RedHat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <95f0bd6b-b480-33ab-4a7c-b864505c32b9@RedHat.com>
Date: Tue, 5 Jul 2016 15:06:30 -0400
MIME-Version: 1.0
In-Reply-To: <151cf713-410a-b073-5c5a-430691fb5e6d@RedHat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/05/2016 02:45 PM, Steve Dickson wrote:
> 
> 
> On 06/25/2016 04:12 PM, Trond Myklebust wrote:
>> [root@leira nfs]# cat /etc/exports
>> /export		-ro,sec=sys,sync	localhost(rw,no_root_squ
>> ash)
>> [root@leira nfs]# exportfs -rv
>> exporting localhost:/export
>> [root@leira nfs]# mount -t nfs localhost:/export /mnt/nfs
>> [root@leira nfs]# mkdir /mnt/nfs/gnurr
>> mkdir: cannot create directory ‘/mnt/nfs/gnurr’: Read-only file system
>>
>>
>> Note that removing the "sec=sys" above causes the test to succeed.
>>
> Well it has something to do with
> 
> commit 9b5c3c6a6571a265a90cfce30345891fac24a67c
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Wed Sep 18 11:50:58 2013 -0400
> 
>     exportfs: insecure/secure should be a secinfo_flag
> 
> Because I commit out the call to secinfo_flags_show(), 
> the export is exported correctly... still looking... 
It turns out the problem has nothing to do that commit
because the export flags that are being passed to it 
are wrong. 

When the sec= specified in the default options the 
flags stored in the  e_secinfo are the default 
export flags and are not being updated by the 
host-specific options.

I'm not sure how this ever worked... :-( 

steved.
