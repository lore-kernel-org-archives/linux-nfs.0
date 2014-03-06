Return-Path: linux-nfs-owner@vger.kernel.org
Received: from xes-mad.com ([216.165.139.218]:28654 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbaCFPaf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 10:30:35 -0500
Date: Thu, 6 Mar 2014 09:30:21 -0600 (CST)
From: Andrew Martin <amartin@xes-inc.com>
To: bhawley@luminex.com
Cc: NeilBrown <neilb@suse.de>, linux-nfs-owner@vger.kernel.org,
        linux-nfs@vger.kernel.org
Message-ID: <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com>
In-Reply-To: <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <20140306145042.6db53f60@notabene.brown> <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com> <20140306163721.0edfb498@notabene.brown> <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry>
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> From: "Brian Hawley" <bhawley@luminex.com>
> 
> I ended up writing a "manage_mounts" script run by cron that compares
> /proc/mounts and the fstab, used ping, and "timeout" messages in
> /var/log/messages to identify filesystems that aren't responding, repeatedly
> do umount -f to force i/o errors back to the calling applications; and when
> missing mounts (in fstab but not /proc/mounts) but were now pingable,
> attempt to remount them.
> 
> 
> For me, timeo and retrans are necessary, but not sufficient.  The chunking to
> rsize/wsize and caching plays a role in how well i/o errors get relayed back
> to the applications doing the i/o.
> 
> You will certainly lose data in these scenario's.
> 
> It would be fantastic if somehow the timeo and retrans were sufficient (ie
> when they fail, i/o errors get back to the applications that queued that i/o
> (or even the i/o that cause the application to pend because the rsize/wsize
> or cache was full).
> 
> You can eliminate some of that behavior with sync/directio, but performance
> becomes abysmal.
> 
> I tried "lazy" it didn't provide the desired effect (they unmounted which
> prevented new i/o's; but existing I/o's never got errors).
This is the problem I am having - I can unmount the filesystem with -l, but
once it is unmounted the existing apache processes are still stuck forever.
Does repeatedly running "umount -f" instead of "umount -l" as you describe
return I/O errors back to existing processes and allow them to stop?


> From: "Jim Rees" <rees@umich.edu>
> Given this is apache, I think if I were doing this I'd use ro,soft,intr,tcp
> and not try to write anything to nfs.
I was using tcp,bg,soft,intr when this problem occurred. I do not know if
apache was attempting to do a write or a read, but it seems that tcp,soft,intr
was not sufficient to prevent the problem. 
