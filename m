Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:55820 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758187Ab2FGINb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 04:13:31 -0400
Message-ID: <4FD06290.7050004@panasas.com>
Date: Thu, 7 Jun 2012 11:13:04 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Namjae Jeon <linkinjeon@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>
Subject: Re: [Problem]NFS Server =?UTF-8?B?4oCTIFVtb3VudCByZXN1bHRzIGluIEQ=?=
 =?UTF-8?B?ZXZpY2UgQnVzeS4=?=
References: <CAKYAXd-HCfcejT=kG-kSXWCmfmxTjrT2o+b3Zan+BCrS1Y2ovw@mail.gmail.com>
In-Reply-To: <CAKYAXd-HCfcejT=kG-kSXWCmfmxTjrT2o+b3Zan+BCrS1Y2ovw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/07/2012 10:47 AM, Namjae Jeon wrote:

> Hi Bruce, Trond.
> 
> As you know, Currently umount results in busy on NFS server although
> user tried to succeed to umount on NFS client.
> I suggest to add umount procedure to avoid umount busy issue.
> When calling umount on NFS client, The resources(exportfs entries
> cache) of mount point will be flushed on NFS server. and umount will
> be succeed without busy issue.
> 
> how do you think about this suggestion ?
> 


I second this request, what is needed so when all clients unmounted,
the system comes back to the sate it was before any clients have
mounted. i.e filesystems is not referenced and may unmount cleanly.
(This also happens with >= 4.0 clients only, so no excuses)

This is a real problem for me, on Fedora machines. Because I export
iscsi devices which are network devices, and in the shutdown procedure
for some reason the "service nfs stop" of the server is much much to
late. the original umount of exofs (-o _netdev) fails because it's
held by NFSD, the iscsi devices go away regardless, and when nfsd
finally releases exofs, it gets deadlocked on some error handling.
OK I know I must fix the stuck-ness, but the problem will remain.
The FS will not unmount cleanly because it will only attempt
an unmount after its devices are gone. This will be solved if
nfsd would release its hold on the FS when all clients are gone.

It was on my TODO to fix this for a long time, but I seem to be
too busy with more urgent matters. (What's the point of fixing the
shutdown if the steady state doesn't work yet)

If someone has investigated the matter and knows what to do I would
appreciate any insights, and/or patches would be wonderful ;-)

> Thanks.
> 

<>

Thanks
Boaz

