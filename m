Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55694 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932308Ab2FGLeC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jun 2012 07:34:02 -0400
Date: Thu, 7 Jun 2012 07:33:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>
Subject: Re: [Problem]NFS Server =?utf-8?B?4oCTIFVt?=
	=?utf-8?Q?ount?= results in Device Busy.
Message-ID: <20120607113358.GB8684@fieldses.org>
References: <CAKYAXd-HCfcejT=kG-kSXWCmfmxTjrT2o+b3Zan+BCrS1Y2ovw@mail.gmail.com>
 <4FD06290.7050004@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FD06290.7050004@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 07, 2012 at 11:13:04AM +0300, Boaz Harrosh wrote:
> On 06/07/2012 10:47 AM, Namjae Jeon wrote:
> > As you know, Currently umount results in busy on NFS server although
> > user tried to succeed to umount on NFS client.
> > I suggest to add umount procedure to avoid umount busy issue.
> > When calling umount on NFS client, The resources(exportfs entries
> > cache) of mount point will be flushed on NFS server. and umount will
> > be succeed without busy issue.
> > 
> > how do you think about this suggestion ?

I'm not sure how adding an "unmount" rpc to the protocol would really
help here, if that's what you're asking for.

If you're just looking for a command you could run on the server after
all the clients have unmounted--"exportfs -f" or "service stop nfsd" (or
equivalent) should do the job.

> I second this request, what is needed so when all clients unmounted,
> the system comes back to the sate it was before any clients have
> mounted. i.e filesystems is not referenced and may unmount cleanly.
> (This also happens with >= 4.0 clients only, so no excuses)
> 
> This is a real problem for me, on Fedora machines. Because I export
> iscsi devices which are network devices, and in the shutdown procedure
> for some reason the "service nfs stop" of the server is much much to
> late.

Sounds like a bug in the Fedora systemd configuration?

> the original umount of exofs (-o _netdev) fails because it's
> held by NFSD, the iscsi devices go away regardless, and when nfsd
> finally releases exofs, it gets deadlocked on some error handling.
> OK I know I must fix the stuck-ness, but the problem will remain.
> The FS will not unmount cleanly because it will only attempt
> an unmount after its devices are gone. This will be solved if
> nfsd would release its hold on the FS when all clients are gone.

Note nfsd doesn't really know when that is.  Even with NFSv4, processes
can be using the filesystem without holding state on the server: they
might just have a current working directory in the filesystem, or have a
device special file open.

> It was on my TODO to fix this for a long time, but I seem to be
> too busy with more urgent matters. (What's the point of fixing the
> shutdown if the steady state doesn't work yet)
> 
> If someone has investigated the matter and knows what to do I would
> appreciate any insights, and/or patches would be wonderful ;-)

My first concern would be to fix any ordering bugs in the systemd
configuration, or any reference count leaks.

--b.
