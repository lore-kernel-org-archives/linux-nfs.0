Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13633 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753537Ab3JVRmi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 13:42:38 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Ben Greear <greearb@candelatech.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Failure to mount nfsv4 on 3.12.0-rc5-wl+
Date: Tue, 22 Oct 2013 17:42:35 +0000
Message-ID: <C85838C2-1267-4CA4-9C17-1F828B33B01B@netapp.com>
References: <5266B15B.4020804@candelatech.com>
 <8F3401DF-10CB-43BB-956B-76D166C4B3EA@netapp.com>
 <826B52B7-CB6C-470C-A890-03E9B534B059@netapp.com>
 <5266B574.7030607@candelatech.com>
In-Reply-To: <5266B574.7030607@candelatech.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 22, 2013, at 1:27 PM, Ben Greear <greearb@candelatech.com>
 wrote:

> On 10/22/2013 10:21 AM, Weston Andros Adamson wrote:
>> … and I think it makes sense to me that this behavior was recently introduced and vers=3 fixes things, because nfsv4 has to do the upcall to GSSD even when sec=sys because it attempts to do krb5i on non superblock related operations (if possible will use, otherwise just uses sys) and this behavior was recently added. NFSv3 does not do this.
>> 
>> -dros
> 
> I have a gssd running on the client, from what I can tell, but no idea if it is working properly
> or not.  It should be whatever is standard with F17.

It's my belief that a GSSD bug is causing this hang and that the bug has been in GSSD for a while, but wasn't hit until recent kernel changes.

I'll share more as soon as I figure it out!

-dros

> 
> [root@ct523-9292 ~]# ps -auxww|grep gss
> root       723  0.0  0.0  35192   504 ?        Ss   10:17   0:00 /usr/sbin/rpc.gssd
> root      5975  0.0  0.0 109408   872 pts/0    S+   10:25   0:00 grep --color=auto gss
> 
> Thanks,
> Ben
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 

