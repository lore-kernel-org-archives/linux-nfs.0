From: Norbert van Bolhuis <nvbolhuis-bYiImlzuGf1HoQZOM9yvow@public.gmane.org>
Subject: Re: exportfs: Warning: /adir does not support NFS export.
Date: Thu, 12 Nov 2009 08:41:25 +0100
Message-ID: <4AFBBC25.5090109@aimvalley.nl>
References: <4AF99861.7030103@aimvalley.nl> <20091110180747.GA15000@fieldses.org> <4AFA6431.9010405@aimvalley.nl> <20091111141318.GA335@fieldses.org> <4AFAC74A.5000503@aimvalley.nl> <20091111175333.GA3951@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr3.xs4all.nl ([194.109.24.23]:1902 "EHLO
	smtp-vbr3.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbZKLHlZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Nov 2009 02:41:25 -0500
In-Reply-To: <20091111175333.GA3951@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 
> Thanks.  From your description, yes, that sounds like a configuration
> that should work.  But maybe there's some detail wrong--could you show
> us the full output of the "mount" and "exportfs -v" commands?
> 

ok.

# mount
proc on /proc type proc (rw)
devpts on /dev/pts type devpts (rw,gid=5,mode=620)
sysfs on /sys type sysfs (rw)
ubi0:rootfs on /flashfs type ubifs (rw)
/flashfs/isd0 on /mountedisd type iso9660 (rw,loop=/dev/loop0,offset=1024)

# exportfs -v
/mountedisd     172.31.0.0/255.255.0.0(ro,wdelay,no_root_squash,no_subtree_check)

thanks for helping me with this.
