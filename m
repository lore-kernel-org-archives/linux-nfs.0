Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14550 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539Ab3JUXpA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 19:45:00 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Ben Greear <greearb@candelatech.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Getting 'not supported' when trying to mount IPv6 NFS v3 server.
Date: Mon, 21 Oct 2013 23:44:55 +0000
Message-ID: <4682F017-7329-4690-B336-233DB50537F0@netapp.com>
References: <52659D69.1020609@candelatech.com>
In-Reply-To: <52659D69.1020609@candelatech.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 21, 2013, at 5:32 PM, Ben Greear <greearb@candelatech.com> wrote:

> So, the problem I reported earlier with failing to unmount was fixed
> by the back-ported patch.
> 
> Now, another problem is reported by my user.  In this case, they are
> trying to mount an IPv6 NFS server using NFSv3.  Kernel is 3.9.11+,
> with patches to support binding mount points to local IP (v4/v6) addresses.
> 
> Some NFS over IPv6 mounts work fine, but some do not.  A reboot of the
> NFS client machine did not fix the problem.
> 
> I have tried to reproduce the problem locally, but so far everything works fine
> for us.
> 
> From my own app's logs:
> 
> # mount -t nfs [4001:1::1:1]:/vol/vol1 /mnt/lf/RDnfse11c0 -o srcaddr=4001:1::1:201,vers=3
> # requested NFS version or transport protocol is not supported
> 
> When this problem happens, I do not see any network traffic when trying to mount.

Did you look for the mount protocol when getting a network trace (filter "rpc" in wireshark).

Could you:

  1) run "rpcdebug -m nfs -s mount" before mounting, post output of dmesg after mount fails.

  2) add -v to the mount command and post the output

  3) maybe get rid of srcaddr= option / post info about the ip configuration
  
-dros

> 
> 
> I am curious if anyone else has seen errors similar to this?
> 
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

