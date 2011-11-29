Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36909 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab1K2PKi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 10:10:38 -0500
MIME-Version: 1.0
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC23@SACMVEXC2-PRD.hq.netapp.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
 <20111129091037.20730.59391.stgit@localhost6.localdomain6>
 <F19688880B763E40B28B2B462677FBF805E3A4AFF2@MX09A.corp.emc.com>
 <4ED4CDCE.9080804@parallels.com> <F19688880B763E40B28B2B462677FBF805E3A4AFFD@MX09A.corp.emc.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC23@SACMVEXC2-PRD.hq.netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 29 Nov 2011 23:10:16 +0800
Message-ID: <CA+a=Yy5GKMu8rbh8y3fOtK6pmqygPNBr=a+p7LfcmTqtXFH3iA@mail.gmail.com>
Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
 blocklayout routines
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: tao.peng@emc.com, skinsbursky@parallels.com, linux-nfs@vger.kernel.org,
        xemul@parallels.com, neilb@suse.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jbottomley@parallels.com,
        bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 29, 2011 at 9:35 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>> -----Original Message-----
>> From: tao.peng@emc.com [mailto:tao.peng@emc.com]
>> Sent: Tuesday, November 29, 2011 7:40 AM
>> To: skinsbursky@parallels.com
>> Cc: Myklebust, Trond; linux-nfs@vger.kernel.org; xemul@parallels.com;
>> neilb@suse.de; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>> jbottomley@parallels.com; bfields@fieldses.org; davem@davemloft.net;
>> devel@openvz.org
>> Subject: RE: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference
>> from blocklayout routines
>>
>> > -----Original Message-----
>> > From: Stanislav Kinsbursky [mailto:skinsbursky@parallels.com]
>> > Sent: Tuesday, November 29, 2011 8:19 PM
>> > To: Peng, Tao
>> > Cc: Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; Pavel
>> > Emelianov; neilb@suse.de; netdev@vger.kernel.org;
>> > linux-kernel@vger.kernel.org; James Bottomley; bfields@fieldses.org;
>> > davem@davemloft.net; devel@openvz.org
>> > Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference
>> > from blocklayout routines
>> >
>> > 29.11.2011 16:00, tao.peng@emc.com пишет:
>> > >> -----Original Message-----
>> > >> From: linux-nfs-owner@vger.kernel.org
>> > >> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of
>> > Stanislav
>> > >> Kinsbursky
>> > >> Sent: Tuesday, November 29, 2011 6:11 PM
>> > >> To: Trond.Myklebust@netapp.com
>> > >> Cc: linux-nfs@vger.kernel.org; xemul@parallels.com; neilb@suse.de;
>> > >> netdev@vger.kernel.org; linux- kernel@vger.kernel.org;
>> > >> jbottomley@parallels.com; bfields@fieldses.org;
>> > >> davem@davemloft.net; devel@openvz.org
>> > >> Subject: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference
>> > >> from blocklayout routines
>> > >>
>> > >> This is a cleanup patch. We don't need this reference anymore,
>> > >> because blocklayout pipes dentries now creates and destroys in
>> > >> per-net operations and on PipeFS mount/umount notification.
>> > >> Note that nfs4blocklayout_register_net() now returns 0 instead of
>> > >> -ENOENT in case of PipeFS superblock absence. This is ok, because
>> > >> blocklayout pipe dentry will be created on PipeFS mount event.
>> > > When is the "pipefs mount event" going to happen? When inserting
>> > > kernel modules or when user issues
>> > mount command?
>> > >
>> >
>> > When user issues mount command.
>> > Kernel mounts of PipeFS has been removed with all these patch sets
>> > I've sent already.
>> Then it is going to break blocklayout user space program blkmapd, which is
>> stared before mounting any file system and it tries to open the pipe file
>> when started.
>
> Why on earth is blkmapd doing this instead of listening for file creation notifications like the other rpc_pipefs daemons do?
Not sure how the original implementer chose this but I think it is
likely because we do not expect the pipe file to be created or deleted
dynamically.

-- 
Thanks,
Tao
