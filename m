Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37976 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750857AbdKQSAH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Nov 2017 13:00:07 -0500
Date: Fri, 17 Nov 2017 13:00:07 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anders Ossowicki <and@vmn.dk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfsd returns NFSERR_STALE when the inode of the rootdir of the
 nfs mount is > 2^32
Message-ID: <20171117180007.GB13501@fieldses.org>
References: <CAOapt6ko9Ue+Vf0TQNNNP+pSdbk09my_b9PjSF21Vg0v0nzAVw@mail.gmail.com>
 <1E02EBE8-9BB2-4E60-BB4D-92843D5A0941@oracle.com>
 <CAOapt6=TOF=Q0rCgQEm-EqML1XNDtWJgjcp7Z5_Qenp8RXMZpw@mail.gmail.com>
 <CAOapt6=wOfUBgTCvMBxs6B=xDQ_wp3VmKqUCuPmcJshiz-CkGA@mail.gmail.com>
 <69343BD5-7121-4FE3-A72F-B7BF4150DAD2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <69343BD5-7121-4FE3-A72F-B7BF4150DAD2@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 15, 2017 at 10:27:49AM -0500, Chuck Lever wrote:
> 
> > On Nov 15, 2017, at 3:14 AM, Anders Ossowicki <and@vmn.dk> wrote:
> > 
> > On 14 November 2017 at 19:11, Anders Ossowicki <and@vmn.dk> wrote:
> >> On 14 November 2017 at 18:12, Chuck Lever <chuck.lever@oracle.com> wrote:
> >>> But since you already have such inodes, NFS clients will
> >>> have to convert the numbers on the fly. You can use a boot
> >>> parameter on your clients:
> >>> 
> >>>  nfs.enable_ino64=0
> >>> 
> >>> According to comments in fs/nfs/inode.c .
> >> 
> >> Thanks for the suggestion.
> >> 
> >> I looked at nfs.enable_ino64 while tracking down this issue, but it
> >> looked like a client-side option to me, and the error happens in the
> >> nfsd code. I'll give a shot tomorrow.
> > 
> > No dice, unfortunately:
> > 
> > aowi@otto ~ $ dmesg|grep 'Kernel command line'
> > [    0.000000] Kernel command line:
> > BOOT_IMAGE=/boot/vmlinuz-3.19.0-77-generic
> > root=UUID=601cb526-8e11-4565-a5ed-0be619db7a5e ro quiet splash
> > nfs.enable_ino64=0 vt.handoff=7
> > aowi@otto ~ $ sudo mount -t nfs svin:/z/svin/aowitest/foo /mnt
> > aowi@otto ~ $ ls /mnt
> > ls: cannot open directory /mnt: Stale file handle
> 
> Does this happen with a recent kernel on the client?
> 
> And, it would help if you can capture and post a raw tcpdump
> of this interaction so we can see all the details of the
> conversation. Start the tcpdump before "sudo mount", and
> save the raw bytes with "-w /tmp/sniffer.pcap". gzip and
> post it here.

Sounds like the server's returning STALE on PUTFH of a filehandle it
presumably just returned....  So that does seem like a pretty clear
bug on the server side, either in knfsd or xfs or exportfs.  Still, it
might be good to see the traffic, yes.

--b.

> 
> What happens if you mount svin:/ and walk down the server's
> namespace into /z/svin/aowitest/foo ?
> 
> 
> --
> Chuck Lever
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
