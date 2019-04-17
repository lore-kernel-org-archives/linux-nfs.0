Return-Path: <SRS0=8+CZ=ST=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0185C282DA
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Apr 2019 16:56:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B6FB120835
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Apr 2019 16:56:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732902AbfDQQ4w (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Apr 2019 12:56:52 -0400
Received: from fieldses.org ([173.255.197.46]:40552 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731454AbfDQQ4v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Apr 2019 12:56:51 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 86CC71E28; Wed, 17 Apr 2019 12:56:50 -0400 (EDT)
Date:   Wed, 17 Apr 2019 12:56:50 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Bruno Santos <bacmsantos@gmail.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: nfs v4.2 leaking file descriptors
Message-ID: <20190417165650.GB18164@fieldses.org>
References: <CANUurQovk32SFS_jDMpgmM-CktFJGF1yd5Fv_JOW2BFe4DsJPg@mail.gmail.com>
 <CANUurQr77yK5q6cKc3oFEeLE0ZdyEDDHmyiWCAWsWqVjfGGgjw@mail.gmail.com>
 <20190416204605.GB6662@fieldses.org>
 <CANUurQpEgZhZFg70ncc+hcnB+3v1K0mfC9N2tYoe4djOwCz1+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CANUurQpEgZhZFg70ncc+hcnB+3v1K0mfC9N2tYoe4djOwCz1+A@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Apr 17, 2019 at 12:11:31PM +0100, Bruno Santos wrote:
> Thank you for the suggestion. I didn't actually know anything about
> the slabinfo, very useful. And yes I can see the link therewith the
> nfsd4_stateids and nfsd4_files increasing over time.

I think the number to watch is the first column ("active_objs").  An
nfsd4_file could reference up to 4 struct files.

If the growth in nfsd4_stateids and nfsd4_files is enough to explain the
increase, then possibly it's some bug on either client or server side
that's preventing the client from closing files.

In that case rebooting the problematic client (maybe just rebooting all
4) should bring the excessive open files back down.

If that doesn't work, then it's the server forgetting to drop references
somewhere even when close (or delegreturn, or whatever) comes as it
should.  In which case it might be interesting to know whether
restarting the server (just systemctl restart nfs-server or similar)
helps.

--b.

> I can also see the following messages appearing on dmesg very frequently
> Server side:
> [5589745.074567] NFSD: client 10.1.10.190 testing state ID with
> incorrect client ID
> [5589745.076382] NFSD: client 10.1.10.83 testing state ID with
> incorrect client ID
> [5589745.077867] NFSD: client 10.1.10.190 testing state ID with
> incorrect client ID
> [5589745.080368] NFSD: client 10.1.10.83 testing state ID with
> incorrect client ID
> [5589745.080998] NFSD: client 10.1.10.190 testing state ID with
> incorrect client ID
> [5589745.085418] NFSD: client 10.1.10.83 testing state ID with
> incorrect client ID
> 
> Also running:
> #tshark -tad -i bond0 -Y "(nfs.status != 0)"
> 25574 2019-04-17 12:09:03.580443721  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 25549) LOOKUP Status: NFS4ERR_NOENT
> 261264 2019-04-17 12:09:39.692976173  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 259893) CLOSE Status: NFS4ERR_OLD_STATEID
> 261273 2019-04-17 12:09:39.705359506  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 260065) CLOSE Status: NFS4ERR_OLD_STATEID
> 261649 2019-04-17 12:09:39.718857437  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 260517) CLOSE Status: NFS4ERR_OLD_STATEID
> 290633 2019-04-17 12:09:41.520550924  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 290588) CLOSE Status: NFS4ERR_OLD_STATEID
> 292829 2019-04-17 12:09:41.572183869  10.1.10.191 → 10.1.10.170  NFS
> 166 [TCP ACKed unseen segment] V4 Reply (Call In 291959) LOOKUP
> Status: NFS4ERR_NOENT
> 297536 2019-04-17 12:09:41.728307777  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 297266) LOOKUP Status: NFS4ERR_NOENT
> 326074 2019-04-17 12:09:43.872781379  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 326073) CLOSE Status: NFS4ERR_OLD_STATEID
> 326079 2019-04-17 12:09:43.873222013  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 326078) CLOSE Status: NFS4ERR_OLD_STATEID
> 326103 2019-04-17 12:09:43.873925732  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 326102) CLOSE Status: NFS4ERR_OLD_STATEID
> 328402 2019-04-17 12:09:44.002984136  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 328400) CLOSE Status: NFS4ERR_OLD_STATEID
> root@ni-hpc-02:~# tshark -tad -i bond0 -Y "(nfs.status != 0)"
> Running as user "root" and group "root". This could be dangerous.
> Capturing on 'bond0'
> 53046 2019-04-17 12:10:44.818936562  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 53043) CLOSE Status: NFS4ERR_OLD_STATEID
> 53048 2019-04-17 12:10:44.818967848  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 53044) CLOSE Status: NFS4ERR_OLD_STATEID
> 53049 2019-04-17 12:10:44.818990681  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 53045) CLOSE Status: NFS4ERR_OLD_STATEID
> 53057 2019-04-17 12:10:44.819085752  10.1.10.191 → 10.1.10.170  NFS
> 410 V4 Reply (Call In 53052) CLOSE Status: NFS4ERR_OLD_STATEID  ; V4
> Reply (Call In 53052) GETATTR
> 53068 2019-04-17 12:10:44.819315507  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 53065) CLOSE Status: NFS4ERR_OLD_STATEID
> 53076 2019-04-17 12:10:44.819542785  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 53074) CLOSE Status: NFS4ERR_OLD_STATEID
> 53672 2019-04-17 12:10:44.908883083  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 53082) CLOSE Status: NFS4ERR_OLD_STATEID
> 88712 2019-04-17 12:10:46.682247016  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 88711) CLOSE Status: NFS4ERR_OLD_STATEID
> 88713 2019-04-17 12:10:46.682262932  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 88711) CLOSE Status: NFS4ERR_OLD_STATEID
> 88725 2019-04-17 12:10:46.683030796  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 88723) CLOSE Status: NFS4ERR_OLD_STATEID
> 88730 2019-04-17 12:10:46.683209944  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 88729) CLOSE Status: NFS4ERR_OLD_STATEID
> 93002 2019-04-17 12:10:46.879404035  10.1.10.191 → 10.1.10.170  NFS
> 898 V4 Reply (Call In 92976) GETATTR  ; V4 Reply (Call In 92990)
> GETATTR  ; V4 Reply (Call In 92997) GETATTR  ; V4 Reply (Call In
> 92999) CLOSE Status: NFS4ERR_OLD_STATEID
> 93052 2019-04-17 12:10:46.880706310  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 93051) CLOSE Status: NFS4ERR_OLD_STATEID
> 93056 2019-04-17 12:10:46.880830245  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 93054) CLOSE Status: NFS4ERR_OLD_STATEID
> 126695 2019-04-17 12:10:48.760521096  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 126567) CLOSE Status: NFS4ERR_OLD_STATEID
> 126700 2019-04-17 12:10:48.760586900  10.1.10.191 → 10.1.10.170  NFS
> 410 V4 Reply (Call In 126568) GETATTR  ; V4 Reply (Call In 126570)
> CLOSE Status: NFS4ERR_OLD_STATEID
> 126704 2019-04-17 12:10:48.760669346  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 126578) CLOSE Status: NFS4ERR_OLD_STATEID
> 126708 2019-04-17 12:10:48.760786205  10.1.10.191 → 10.1.10.170  NFS
> 410 V4 Reply (Call In 126586) GETATTR  ; V4 Reply (Call In 126587)
> CLOSE Status: NFS4ERR_OLD_STATEID
> 226205 2019-04-17 12:10:56.798335876  10.1.10.191 → 10.1.10.170  NFS
> 266 V4 Reply (Call In 226170) OPEN Status: NFS4ERR_DELAY  ; V4 Reply
> (Call In 226199) TEST_STATEID
> 226206 2019-04-17 12:10:56.798412890  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 226200) OPEN Status: NFS4ERR_DELAY
> 253665 2019-04-17 12:10:58.048772590  10.1.10.191 → 10.1.10.170  NFS
> 1470 V4 Reply (Call In 253658) READV4 Reply (Call In 253659) CLOSE  ;
> V4 Reply (Call In 253661) CLOSE Status: NFS4ERR_OLD_STATEID
> 253671 2019-04-17 12:10:58.048952402  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 253667) CLOSE Status: NFS4ERR_OLD_STATEID
> 368579 2019-04-17 12:11:04.582691779  10.1.10.191 → 10.1.10.170  NFS
> 166 V4 Reply (Call In 368574) CLOSE Status: NFS4ERR_BAD_STATEID
> ^C66792 packets dropped
> 23 packets captured
> 
> There seems to be nothing on any of those clients side of things.
> 
> Bruno
> 
> 
> On Tue, 16 Apr 2019 at 21:46, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Mon, Apr 15, 2019 at 06:00:56PM +0100, Bruno Santos wrote:
> > > We have a debian stretch HPC cluster(#1 SMP Debian 4.9.130-2
> > > (2018-10-27)). One of the machines mounts a couple of drives from a
> > > Dell compellent system and shares it across a 10GB network to 4
> > > different machines.
> > >
> > > We had the nfs server crashing a few weeks ago because the file-max
> > > limit had been reached. At the time we increased the number of file
> > > handles it can handle and been monitoring since. We have noticed that
> > > the number of entries on that machine keeps increasing though and
> > > despite our best efforts we have been unable identify the cause.
> > > Anything I can find related to this is from a well known bug in 2011
> > > and nothing afterwards. We are assuming this is caused but a leak of
> > > file handles on the nfs side but not sure.
> > >
> > > Does anyone has anyway of figuring out what is causing this? Output
> > > from the file-ne, lsof, etc is below.
> >
> > Off the top of my head, the only idea I have is to try watching
> >
> >         grep nfsd4 /proc/slabinfo
> >
> > and see if any of those objects are also leaking.
> >
> > --b.
> >
> > >
> > > Thank you very much for any help you can provide.
> > >
> > > Best regards,
> > > Bruno Santos
> > >
> > > :~# while :;do echo "$(date): $(cat /proc/sys/fs/file-nr)";sleep
> > > 30;done
> > > Mon 15 Apr 17:23:11 BST 2019: 2466176   0       4927726
> > > Mon 15 Apr 17:23:41 BST 2019: 2466176   0       4927726
> > > Mon 15 Apr 17:24:11 BST 2019: 2466336   0       4927726
> > > Mon 15 Apr 17:24:41 BST 2019: 2466240   0       4927726
> > > Mon 15 Apr 17:25:11 BST 2019: 2466560   0       4927726
> > > Mon 15 Apr 17:25:41 BST 2019: 2466336   0       4927726
> > > Mon 15 Apr 17:26:11 BST 2019: 2466400   0       4927726
> > > Mon 15 Apr 17:26:41 BST 2019: 2466432   0       4927726
> > > Mon 15 Apr 17:27:11 BST 2019: 2466688   0       4927726
> > > Mon 15 Apr 17:27:41 BST 2019: 2466624   0       4927726
> > > Mon 15 Apr 17:28:11 BST 2019: 2466784   0       4927726
> > > Mon 15 Apr 17:28:41 BST 2019: 2466688   0       4927726
> > > Mon 15 Apr 17:29:11 BST 2019: 2466816   0       4927726
> > > Mon 15 Apr 17:29:42 BST 2019: 2466752   0       4927726
> > > Mon 15 Apr 17:30:12 BST 2019: 2467072   0       4927726
> > > Mon 15 Apr 17:30:42 BST 2019: 2466880   0       4927726
> > >
> > > ~# lsof|wc -l
> > > 3428
