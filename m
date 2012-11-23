Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23152 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752787Ab2KWTEV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Nov 2012 14:04:21 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "dE ." <de.techno@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Slow NFS loop performance.
Date: Fri, 23 Nov 2012 19:04:19 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9092F876C@SACEXCMBX04-PRD.hq.netapp.com>
References: <50AF57A3.3090000@gmail.com>
In-Reply-To: <50AF57A3.3090000@gmail.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

You're using a non-default timeo=60 on a TCP connection.

Why?

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of dE .
> Sent: Friday, November 23, 2012 6:02 AM
> To: linux-nfs@vger.kernel.org
> Subject: Slow NFS loop performance.
> 
> Humm... The last thing I expected was no response even in the mailing list.
> 
> So I'm filing a bug on this.
> 
> On Oct 23, 2012 2:19 PM, "dE ." <de.techno@gmail.com> wrote:
>  > Hi!
>  >
>  > Great job with NFS server, it surely is fast, but not on loop devices.
>  >
>  > If I loop mount a file and share the mount point over NFS3 or NFS4, the  >
> write performance of the client on the loop mounted share is pretty bad.
>  >
>  > On a 100 Mbps (or 12.5MBps) full duplex Ethernet link, I get ~8MBps  >
> speeds, whereas on the loop mounted device, I get at best 6MBps.
>  >
>  > Any ideas why?
>  >
>  > My server configuration (NFS4) --
>  >
> anonuid=1000,anongid=1000,**secure,no_subtree_check,rw,**fsid=0,cross
> mnt
>  >
>  > My client mount options --
>  > rsize=1048576,wsize=1048576,**async,hard,timeo=60,retrans=2,**
>  > actimeo=900,retry=2,**lookupcache=pos,nfsvers=4,**
>  > nolock,intr,noacl,rdirplus
>  >
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
