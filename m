Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50958 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755847Ab2HPPW1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Aug 2012 11:22:27 -0400
Message-ID: <502D0FF3.8010302@netapp.com>
Date: Thu, 16 Aug 2012 11:21:23 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: William Dauchy <wdauchy@gmail.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS: Clear key construction data if the idmap upcall
 fails
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com> <CAJ75kXYtPjQ2zhL+Kw6+duT-fMDh9f-oHviHGjSwvYT=wtStzw@mail.gmail.com> <CAJ75kXZSV=gCX1CYFocLHiHf_7D13ysk35cA-y0pyCiDzpnT3w@mail.gmail.com> <CAJ75kXbdvKiGt9bYvD1Wu-b6ZkVS0yG2YdkkuS7O+r_-+ynPWQ@mail.gmail.com>
In-Reply-To: <CAJ75kXbdvKiGt9bYvD1Wu-b6ZkVS0yG2YdkkuS7O+r_-+ynPWQ@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/16/2012 11:07 AM, William Dauchy wrote:
> On Thu, Aug 16, 2012 at 3:45 PM, William Dauchy <wdauchy@gmail.com> wrote:
>> On another setup, this patch is breaking the legacy mapping.
>> rpc.idmapd is running but it can't map any user. I'm trying to see the
>> difference with the previous test I made.
> 
> my second test is on 64 bits (the previous was on 32 bits).
> I'm also getting many errors from the userland:
> rpc.idmapd: nfscb: write(/var/lib/nfs/rpc_pipefs/nfs/clnt4/idmap): No
> space left on device
> 
> I assume this is because of adding `im_private` in `struct idmap_msg`
> since removing the field resolves the issue.
> I tried to find a wrong sizeof regarding `struct idmap_msg` but didn’t
> found any thing at the moment.
> 

I was afraid im_private would cause problems, but I wouldn't expect "No space left on device".  You did double check the output of `df`, right? :).

I'll play around with it soon to see what I can find.  Thanks for finding this!

- Bryan

