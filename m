Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47708 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932501AbdKOP1x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Nov 2017 10:27:53 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: nfsd returns NFSERR_STALE when the inode of the rootdir of the nfs mount is > 2^32
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAOapt6=wOfUBgTCvMBxs6B=xDQ_wp3VmKqUCuPmcJshiz-CkGA@mail.gmail.com>
Date: Wed, 15 Nov 2017 10:27:49 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <69343BD5-7121-4FE3-A72F-B7BF4150DAD2@oracle.com>
References: <CAOapt6ko9Ue+Vf0TQNNNP+pSdbk09my_b9PjSF21Vg0v0nzAVw@mail.gmail.com> <1E02EBE8-9BB2-4E60-BB4D-92843D5A0941@oracle.com> <CAOapt6=TOF=Q0rCgQEm-EqML1XNDtWJgjcp7Z5_Qenp8RXMZpw@mail.gmail.com> <CAOapt6=wOfUBgTCvMBxs6B=xDQ_wp3VmKqUCuPmcJshiz-CkGA@mail.gmail.com>
To: Anders Ossowicki <and@vmn.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 15, 2017, at 3:14 AM, Anders Ossowicki <and@vmn.dk> wrote:
> 
> On 14 November 2017 at 19:11, Anders Ossowicki <and@vmn.dk> wrote:
>> On 14 November 2017 at 18:12, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> But since you already have such inodes, NFS clients will
>>> have to convert the numbers on the fly. You can use a boot
>>> parameter on your clients:
>>> 
>>>  nfs.enable_ino64=0
>>> 
>>> According to comments in fs/nfs/inode.c .
>> 
>> Thanks for the suggestion.
>> 
>> I looked at nfs.enable_ino64 while tracking down this issue, but it
>> looked like a client-side option to me, and the error happens in the
>> nfsd code. I'll give a shot tomorrow.
> 
> No dice, unfortunately:
> 
> aowi@otto ~ $ dmesg|grep 'Kernel command line'
> [    0.000000] Kernel command line:
> BOOT_IMAGE=/boot/vmlinuz-3.19.0-77-generic
> root=UUID=601cb526-8e11-4565-a5ed-0be619db7a5e ro quiet splash
> nfs.enable_ino64=0 vt.handoff=7
> aowi@otto ~ $ sudo mount -t nfs svin:/z/svin/aowitest/foo /mnt
> aowi@otto ~ $ ls /mnt
> ls: cannot open directory /mnt: Stale file handle

Does this happen with a recent kernel on the client?

And, it would help if you can capture and post a raw tcpdump
of this interaction so we can see all the details of the
conversation. Start the tcpdump before "sudo mount", and
save the raw bytes with "-w /tmp/sniffer.pcap". gzip and
post it here.

What happens if you mount svin:/ and walk down the server's
namespace into /z/svin/aowitest/foo ?


--
Chuck Lever



