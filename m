Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:49736 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245Ab3JVR1R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 13:27:17 -0400
Message-ID: <5266B574.7030607@candelatech.com>
Date: Tue, 22 Oct 2013 10:27:16 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Failure to mount nfsv4 on 3.12.0-rc5-wl+
References: <5266B15B.4020804@candelatech.com> <8F3401DF-10CB-43BB-956B-76D166C4B3EA@netapp.com> <826B52B7-CB6C-470C-A890-03E9B534B059@netapp.com>
In-Reply-To: <826B52B7-CB6C-470C-A890-03E9B534B059@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/22/2013 10:21 AM, Weston Andros Adamson wrote:
> … and I think it makes sense to me that this behavior was recently introduced and vers=3 fixes things, because nfsv4 has to do the upcall to GSSD even when sec=sys because it attempts to do krb5i on non superblock related operations (if possible will use, otherwise just uses sys) and this behavior was recently added. NFSv3 does not do this.
> 
> -dros

I have a gssd running on the client, from what I can tell, but no idea if it is working properly
or not.  It should be whatever is standard with F17.

[root@ct523-9292 ~]# ps -auxww|grep gss
root       723  0.0  0.0  35192   504 ?        Ss   10:17   0:00 /usr/sbin/rpc.gssd
root      5975  0.0  0.0 109408   872 pts/0    S+   10:25   0:00 grep --color=auto gss

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

