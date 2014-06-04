Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f169.google.com ([209.85.128.169]:58635 "EHLO
	mail-ve0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbaFDUmJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 16:42:09 -0400
Received: by mail-ve0-f169.google.com with SMTP id jx11so65028veb.0
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 13:42:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <005d01cf801f$363aabf0$a2b003d0$@iozone.org>
References: <004501cf8013$7a3373c0$6e9a5b40$@iozone.org>
	<005d01cf801f$363aabf0$a2b003d0$@iozone.org>
Date: Wed, 4 Jun 2014 16:42:07 -0400
Message-ID: <CAHQdGtQ9ceYQJD0eEehLhq1T2KsWRv11hkOVg9=NdpS9h4OJLA@mail.gmail.com>
Subject: Re: FW: Forwarding request at suggestion from support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: capps@iozone.org
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Don,

On Wed, Jun 4, 2014 at 2:02 PM, Iozone <capps@iozone.org> wrote:
>
>
> From: Iozone [mailto:capps@iozone.org]
> Sent: Wednesday, June 04, 2014 11:39 AM
> To: linux-nfs@vger.kernel.org
> Subject: Forwarding request at suggestion from support
>
>                 Dear kernel folks,
>
>                                 Please take a look at Bugzilla bug:
>
> https://bugzilla.redhat.com/show_bug.cgi?id=1104696
>
> Description of problem:
>
>    Linux NFSv3 clients can issue extra reads beyond EOF.
>
> Condition of the test:  (32KB_file is a file that is 32KB in size)
>           File is being read over an NFSv3 mount.
>
>           dd if=/mnt/32KB_file  of=/dev/null iflag=direct bs=1M count=1
>
> What one should expect over the wire:
>           NFSv3_read for 32k, or NFS_read for 1M
>           NFSv3_read Reply return of 32KB and EOF set.
>
> What happens with Linux NFSv3 client:
>           NFSv3 read for 128k
>           NFSv3 read for 128k,
>           NFSv3 read for 128k,
>           NFSv3 read for 128k,
>           NFSv3 read for 128k,
>           NFSv3 read for 128k,
>           NFSv3 read for 128k,
>           NFSv3 read for 128k.
>        followed by:
>           NFSv3 read reply of 32k,
>           NFSv3 read reply of 0,
>           NFSv3 read reply of 0,
>           NFSv3 read reply of 0,
>           NFSv3 read reply of 0,
>           NFSv3 read reply of 0,
>           NFSv3 read reply of 0,
>           NFSv3 read reply of 0.
>
> So… instead of a single round trip with a short read length returned, there
> were 8 async I/O ops sent to the NFS server, and 8 replies from the NFS
> server.
> The client knew the file size before even sending the very first request,
> but
> went ahead and issued an large number of reads that it should have known
> were
> beyond EOF.
>
> This client behavior hammers NFS servers with requests that are guaranteed
> to always fail, and burn
> CPU cycles, for operations that it knew were pointless.
>
> While the application is getting correct answers to the API calls, the poor
> client and server are beating each other senseless over the wire.
>
> NOTE: This only happens if O_DIRECT is being used… (thus the iflag=direct)

Yes. This behaviour is intentional in the case of O_DIRECT. The reason
why we should not change it is that we don't ever want to rely on
cached values for the file size when doing uncached I/O.
An application such as Oracle may have out-of-band information about
writes to the file that were made by another client directly to the
server, in which case it would be wrong for the kernel to truncate
those reads based on its cached information.

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
