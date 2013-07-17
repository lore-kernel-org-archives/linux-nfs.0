Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f41.google.com ([209.85.212.41]:42667 "EHLO
	mail-vb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab3GQGrv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jul 2013 02:47:51 -0400
Received: by mail-vb0-f41.google.com with SMTP id p13so1101895vbe.14
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jul 2013 23:47:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130702170216.GH30876@gandi.net>
References: <20130702170216.GH30876@gandi.net>
From: William Dauchy <william@gandi.net>
Date: Wed, 17 Jul 2013 08:47:30 +0200
Message-ID: <CAJ75kXbTxrY6i2itGPOjZamGmLFH83kF33RnRnjFVo=deJkxUQ@mail.gmail.com>
Subject: Re: Strange NFS/async write issue
To: William Dauchy <william@gandi.net>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Pascal Bouchareine <pascal@gandi.net>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Tue, Jul 2, 2013 at 7:02 PM, William Dauchy <william@gandi.net> wrote:
> We wrote the attached tester to reproduce an issue we have with mysql on
> a 3.9.8 kernel using a nfsv4 mount.
>
> mount options are "classic":
>
> rw,nosuid,nodev,noexec,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,local_lock=none
>
> When handling a temporary file, mysql open(), then writes a bunch (say ~16MB) of data
> to that file, lseeks to the start and re-reads file contents.
>
> With the code as attached, we see a lot of small NFS writes (1400 bytes) and
> a lot of getattrs [1] and the test takes a little more than 2 seconds.
>
> It seems the lseek/read are serialized to the last write actually sent to the filer -
> and nothing aggregates the big writes.
>
> If we uncomment the fsync() call, or simply close() and reopen the file, the test
> completes in a few milliseconds. Same if we call sync() from any process while this
> test is running. Dump shows lots of big tcp pushes, few NFS commands/answers - no
> getattr in between writes.
>
> Is this an issue worth a dig or a known behaviour?
> Can we debug this a bit further for you?
>
> Thanks for your time,
>
> [1]
> (extract from the dump:
> 15:56:43.681766 IP 10.0.46.65.813 > 10.0.41.39.2049: Flags [P.], seq 14399980:14401384, ack 1038253, win 24576, options [nop,nop,TS val 928349822 ecr 259987202], length 1404
> 15:56:43.685189 IP 10.0.41.39.2049 > 10.0.46.65.813: Flags [.], ack 14399980, win 32715, options [nop,nop,TS val 259987203 ecr 928349822], length 0
> 15:56:43.689131 IP 10.0.41.39.2049 > 10.0.46.65.263281194: reply ok 132 getattr NON 3 ids 0/38 sz 0
> 15:56:43.689292 IP 10.0.46.65.280058410 > 10.0.41.39.2049: 2892 getattr fh 0,0/22
> 15:56:43.689330 IP 10.0.46.65.813 > 10.0.41.39.2049: Flags [P.], seq 14404280:14405684, ack 1038389, win 24576, options [nop,nop,TS val 928349824 ecr 259987203], length 1404
> 15:56:43.690127 IP 10.0.41.39.2049 > 10.0.46.65.813: Flags [.], ack 14404280, win 32715, options [nop,nop,TS val 259987203 ecr 928349824], length 0
> 15:56:43.690651 IP 10.0.41.39.2049 > 10.0.46.65.280058410: reply ok 132 getattr NON 3 ids 0/38 sz 0
> 15:56:43.690769 IP 10.0.46.65.296835626 > 10.0.41.39.2049: 2892 getattr fh 0,0/22
> 15:56:43.690782 IP 10.0.46.65.813 > 10.0.41.39.2049: Flags [P.], seq 14408580:14409984, ack 1038525, win 24576, options [nop,nop,TS val 928349824 ecr 259987203], length 1404
> 15:56:43.691496 IP 10.0.41.39.2049 > 10.0.46.65.813: Flags [.], ack 14408580, win 32715, options [nop,nop,TS val 259987203 ecr 928349824], length 0
> 15:56:43.692970 IP 10.0.41.39.2049 > 10.0.46.65.296835626: reply ok 132 getattr NON 3 ids 0/38 sz 0
> 15:56:43.693194 IP 10.0.46.65.313612842 > 10.0.41.39.2049: 2892 getattr fh 0,0/22
> 15:56:43.693249 IP 10.0.46.65.813 > 10.0.41.39.2049: Flags [P.], seq 14412880:14414284, ack 1038661, win 24576, options [nop,nop,TS val 928349825 ecr 259987204], length 1404
> 15:56:43.693395 IP 10.0.41.39.2049 > 10.0.46.65.813: Flags [.], ack 14412880, win 32715, options [nop,nop,TS val 259987204 ecr 928349825], length 0
> 15:56:43.693644 IP 10.0.41.39.2049 > 10.0.46.65.313612842: reply ok 132 getattr NON 3 ids 0/38 sz 0
> )

Any thoughts about that?

Best regards,
--
William
