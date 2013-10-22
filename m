Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:62738 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380Ab3JVRSR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 13:18:17 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Ben Greear <greearb@candelatech.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Failure to mount nfsv4 on 3.12.0-rc5-wl+
Date: Tue, 22 Oct 2013 17:18:11 +0000
Message-ID: <8F3401DF-10CB-43BB-956B-76D166C4B3EA@netapp.com>
References: <5266B15B.4020804@candelatech.com>
In-Reply-To: <5266B15B.4020804@candelatech.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 22, 2013, at 1:09 PM, Ben Greear <greearb@candelatech.com> wrote:

> This is on an un-hacked upstream kernel (ath tree).  Mounting an older
> Fedora 13 system with nfsv3 works fine, but mounting a F17 box with
> NFSv4 hangs.  Ctrl-c of the process yields this error:
> 
> NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO

I have seen this error message and I'm currently debugging it - it's due to a hang in GSSD upcall.  This message is generated when the user ^Cs the mount. This is reproducible, but the hang only happens for me every once in a while. I can make it happen pretty reliably if I call mount/unmount a bunch of times (like the test_sec_options.sh script I posted last week).

This issue is next on my list...

-dros

> 
> 3.9 kernels on this same system mount the F17 box fine.
> 
> If I add 'vers=3' to /etc/fstab, then it mounts the F17 box fine.
> 
> Thanks,
> Ben
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

