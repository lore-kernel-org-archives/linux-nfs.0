Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:49722 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787Ab3JVRZo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 13:25:44 -0400
Message-ID: <5266B516.4080507@candelatech.com>
Date: Tue, 22 Oct 2013 10:25:42 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Failure to mount nfsv4 on 3.12.0-rc5-wl+
References: <5266B15B.4020804@candelatech.com> <8F3401DF-10CB-43BB-956B-76D166C4B3EA@netapp.com>
In-Reply-To: <8F3401DF-10CB-43BB-956B-76D166C4B3EA@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/22/2013 10:18 AM, Weston Andros Adamson wrote:
> 
> On Oct 22, 2013, at 1:09 PM, Ben Greear <greearb@candelatech.com> wrote:
> 
>> This is on an un-hacked upstream kernel (ath tree).  Mounting an older
>> Fedora 13 system with nfsv3 works fine, but mounting a F17 box with
>> NFSv4 hangs.  Ctrl-c of the process yields this error:
>>
>> NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO
> 
> I have seen this error message and I'm currently debugging it - it's due to a hang in GSSD upcall.  This message is generated when the user ^Cs the mount. This is reproducible, but the hang only happens for me every once in a while. I can make it happen pretty reliably if I call mount/unmount a bunch of times (like the test_sec_options.sh script I posted last week).
> 
> This issue is next on my list...

Ok, no problem.  The vers=3 thing is fine for me.

I do seem to have a good system for reproducing the problem if you
create some patches for testing...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

