Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:53117 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758194AbcDHTE7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Apr 2016 15:04:59 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1aobiC-0005Gz-Vk
	for linux-nfs@vger.kernel.org; Fri, 08 Apr 2016 21:04:57 +0200
Received: from p579d0048.dip0.t-ipconnect.de ([87.157.0.72])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 08 Apr 2016 21:04:56 +0200
Received: from holger.hoffstaette by p579d0048.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 08 Apr 2016 21:04:56 +0200
To: linux-nfs@vger.kernel.org
From: Holger =?iso-8859-1?q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: Strange "SECINFO: security flavor .." messages
Date: Fri, 8 Apr 2016 19:04:51 +0000 (UTC)
Message-ID: <pan$3f049$c5b0e40$570dbaa6$1e5a0be2@googlemail.com>
References: <pan$2228f$c97142f2$8c4f16d6$23d82166@googlemail.com>
	<20160408184111.GB25179@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 08 Apr 2016 14:41:11 -0400, J. Bruce Fields wrote:

> On Thu, Apr 07, 2016 at 10:38:55PM +0000, Holger Hoffstätte wrote:
>> Hi,
>> 
>> After restarting my server and a client re-automounts, I see the
>> following in the server's dmesg:
>> 
>> [  706.454187] NFS: SECINFO: security flavor 390003 is not supported
>> [  706.454621] NFS: SECINFO: security flavor 390004 is not supported
>> [  706.455057] NFS: SECINFO: security flavor 390005 is not supported
>> 
>> I've been completely unsuccessful in trying to discern what these
>> mean and how I can get rid of them; they don't seem to be harmful
>> since everything else works just fine, and has done so for years.
>> I think this started with NFS 4.2 not too long ago, but don't remember
>> for certain. The server exports several mounts, ext4 and xfs.
>> Clients use only NFS v4 via automount. All on 4.4.6.
> 
> What does "exportfs -v" say?

The same for every export (please hold your nose ;), e.g.

/home/holger 192.168.100.0/24(rw,async,wdelay,insecure,no_root_squash,no_subtree_check,sec=sys,rw,insecure,no_root_squash,no_all_squash)
..etc..

Apparently I specify redundant (default) options for the exports, but
whatever.

> What about "cat /proc/net/rpc/nfsd.export/content" right after the
> client's mount/remount?

Right now:

$cat /proc/net/rpc/nfsd.export/content 
#path domain(flags)
/home/holger	192.168.100.0/24(rw,insecure,no_root_squash,async,wdelay,no_subtree_check,uuid=deeff5a9:4d0144ae:9b74badc:38c506cb,sec=1)

> From a quick glance at the code--I think that means the server believes
> that the given export is meant to be available using the krb5 flavors
> (krb5, krb5i, krb5p), but that the kernel doesn't support that flavor.

Interesting! Indeed, the increasing number looks like an attempt
at protocol negotiation - I just didn't associate that with krb.

I have built nfs-utils on both server and client without kerberos
support, maybe I should enable that? I'd rather not without a good
reason, though.

> If that's because you've got something like "sec=sys:krb5:krb5i:krb5p"
> set on that export, then that's a little odd and I think worth warning
> about--you've asked the kernel to do something it can't do.

Nothing of the sort. Security is no issue at all since I'm the only user
here.

thanks,
Holger

