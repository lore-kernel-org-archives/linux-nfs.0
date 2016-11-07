Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55328 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751316AbcKGTgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 Nov 2016 14:36:22 -0500
Subject: Re: [Libtirpc-devel] [PATCH - rpcbind] Provide systemd unit files for
 rpcbind
To: NeilBrown <neilb@suse.com>, Thorsten Kukuk <kukuk@suse.de>
References: <87oa2q14yc.fsf@notabene.neil.brown.name>
 <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com>
 <87r36vq85k.fsf@notabene.neil.brown.name>
 <ff5e0322-2f5e-9102-326f-1f23968cb0a8@RedHat.com>
 <20161102134902.GA6446@suse.de>
 <34b0c398-c77f-41e3-4719-158f2190661c@RedHat.com>
 <87a8dhr39t.fsf@notabene.neil.brown.name>
 <bf20e38d-6129-688f-42b8-aad97334daea@RedHat.com>
 <874m3pqun2.fsf@notabene.neil.brown.name>
Cc: linux-nfs@vger.kernel.org, libtirpc-devel@lists.sourceforge.net
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <fb4dfafe-85ed-6f41-07a0-dd1e7714d6f8@RedHat.com>
Date: Mon, 7 Nov 2016 14:36:21 -0500
MIME-Version: 1.0
In-Reply-To: <874m3pqun2.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/02/2016 08:22 PM, NeilBrown wrote:
> On Thu, Nov 03 2016, Steve Dickson wrote:
>> Yes... basically
>>  
>> -bin_PROGRAMS = rpcbind rpcinfo
>> +sbin_PROGRAMS = rpcbind rpcinfo
> Maybe
>
> -options like `--bindir=DIR' to specify different values for particular
> +options like `--sbindir=DIR' to specify different values for particular
>
> in INSTALL too??
I just left it alone... its been that way for years... Why fix something
that is not broken! ;-)

>> and that seems to work... all this means the rpm spec file
>> will have to be tweaked when a new release is made.
>>
>> All I'll for checking in these systemd file with the comments
>> from the systemd people and the bin=>sbin change.
>>
>> How about a respin?
> Attached
Thank you... Committed!

steved.
>
> Thanks,
> NeilBrown
>

