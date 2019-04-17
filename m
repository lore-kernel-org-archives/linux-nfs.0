Return-Path: <SRS0=8+CZ=ST=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3DE4C10F12
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Apr 2019 11:11:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 69F5D20645
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Apr 2019 11:11:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZAOyGnsM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731116AbfDQLLn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Apr 2019 07:11:43 -0400
Received: from mail-ot1-f68.google.com ([209.85.210.68]:44378 "EHLO
        mail-ot1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729522AbfDQLLn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Apr 2019 07:11:43 -0400
Received: by mail-ot1-f68.google.com with SMTP id d24so20293314otl.11
        for <linux-nfs@vger.kernel.org>; Wed, 17 Apr 2019 04:11:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=ydoLp+wZERTxZi8KGtthumIVkTvt2IZWW6rMATIUIGc=;
        b=ZAOyGnsMToxUgY24evZ3WbOj7NZpA0Ergfj6h+es6EGWsMw3U6+hTJ3RDOB7wWZvBH
         yCgW3Z9nVYWmaw2IULPnSGgMvz2WaAgLaE0N4hGt16LUzidSG8YwkfKMIKJRUW84uYEc
         z31tU2XFAuSqR3L3NFwwObDil5XN19UJySBmFIFEwfr1qtV5UmvFHW4/MqTpkzU24Tbg
         wmCi9JxO6njrKGdekyR+k0r0vIzkchd7uq7uP1Mb+8xGm80bFJTpTJJ4F25Ywi7P3aW9
         2RpPd9M/3FClhHdCFxJb5AYozJ+RTIMzCwrZXUTPDCT671WZZoyw8n0ds7JK4yzk3p1b
         8w3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=ydoLp+wZERTxZi8KGtthumIVkTvt2IZWW6rMATIUIGc=;
        b=OGkeTXaKHkWEXfEmphS5XddXZGE2fczJkqvvFEP45crWSfkOO0s1Ls7//MoB4DQQwq
         D5Jt1CpNT/pvgGbCfFbm2SjHcBPdT+SXn13ycjmoUCMyO86HQJEiySthU0IoY3DFHXUl
         5JlfCrH42Hn7jqvpaXlu3yqPFhSJdpYV+05282bKNXa61YB2jfN/g+9nmm0qYG4LxIX3
         tqsmOSXThW3FDs67050VKXAfMUiklnimXntB2a+T0qWcrYxoc49BPydPMRYGn9FRIPe7
         HIemHUtiXP9Ktik7YdDz+e8Xc428LbwUgcx0CjYdL4YSL4IUaRBbluim5vtr4UL8T8nd
         lIxw==
X-Gm-Message-State: APjAAAXO9vPAl4PST3hqrnRmjsgoNbm2BOa/SY4ultGdESoaKFZ1NEHZ
        Rbd0BYcX801y9w6j0Ao3f4JfiY4hmlfAsDb5Cms=
X-Google-Smtp-Source: APXvYqzXFjnMKnenhoJ66P5P1Jxah+LwJPE5pc7R1+vGRYMevqocqjIK2lvQ8s87whRnD3SCk5EOllr0queYGLXka8s=
X-Received: by 2002:a9d:7f90:: with SMTP id t16mr57112110otp.9.1555499502365;
 Wed, 17 Apr 2019 04:11:42 -0700 (PDT)
MIME-Version: 1.0
References: <CANUurQovk32SFS_jDMpgmM-CktFJGF1yd5Fv_JOW2BFe4DsJPg@mail.gmail.com>
 <CANUurQr77yK5q6cKc3oFEeLE0ZdyEDDHmyiWCAWsWqVjfGGgjw@mail.gmail.com> <20190416204605.GB6662@fieldses.org>
In-Reply-To: <20190416204605.GB6662@fieldses.org>
From:   Bruno Santos <bacmsantos@gmail.com>
Date:   Wed, 17 Apr 2019 12:11:31 +0100
Message-ID: <CANUurQpEgZhZFg70ncc+hcnB+3v1K0mfC9N2tYoe4djOwCz1+A@mail.gmail.com>
Subject: Re: Fwd: nfs v4.2 leaking file descriptors
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thank you for the suggestion. I didn't actually know anything about
the slabinfo, very useful. And yes I can see the link therewith the
nfsd4_stateids and nfsd4_files increasing over time.
I can also see the following messages appearing on dmesg very frequently
Server side:
[5589745.074567] NFSD: client 10.1.10.190 testing state ID with
incorrect client ID
[5589745.076382] NFSD: client 10.1.10.83 testing state ID with
incorrect client ID
[5589745.077867] NFSD: client 10.1.10.190 testing state ID with
incorrect client ID
[5589745.080368] NFSD: client 10.1.10.83 testing state ID with
incorrect client ID
[5589745.080998] NFSD: client 10.1.10.190 testing state ID with
incorrect client ID
[5589745.085418] NFSD: client 10.1.10.83 testing state ID with
incorrect client ID

Also running:
#tshark -tad -i bond0 -Y "(nfs.status !=3D 0)"
25574 2019-04-17 12:09:03.580443721  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 25549) LOOKUP Status: NFS4ERR_NOENT
261264 2019-04-17 12:09:39.692976173  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 259893) CLOSE Status: NFS4ERR_OLD_STATEID
261273 2019-04-17 12:09:39.705359506  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 260065) CLOSE Status: NFS4ERR_OLD_STATEID
261649 2019-04-17 12:09:39.718857437  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 260517) CLOSE Status: NFS4ERR_OLD_STATEID
290633 2019-04-17 12:09:41.520550924  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 290588) CLOSE Status: NFS4ERR_OLD_STATEID
292829 2019-04-17 12:09:41.572183869  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 [TCP ACKed unseen segment] V4 Reply (Call In 291959) LOOKUP
Status: NFS4ERR_NOENT
297536 2019-04-17 12:09:41.728307777  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 297266) LOOKUP Status: NFS4ERR_NOENT
326074 2019-04-17 12:09:43.872781379  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 326073) CLOSE Status: NFS4ERR_OLD_STATEID
326079 2019-04-17 12:09:43.873222013  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 326078) CLOSE Status: NFS4ERR_OLD_STATEID
326103 2019-04-17 12:09:43.873925732  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 326102) CLOSE Status: NFS4ERR_OLD_STATEID
328402 2019-04-17 12:09:44.002984136  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 328400) CLOSE Status: NFS4ERR_OLD_STATEID
root@ni-hpc-02:~# tshark -tad -i bond0 -Y "(nfs.status !=3D 0)"
Running as user "root" and group "root". This could be dangerous.
Capturing on 'bond0'
53046 2019-04-17 12:10:44.818936562  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 53043) CLOSE Status: NFS4ERR_OLD_STATEID
53048 2019-04-17 12:10:44.818967848  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 53044) CLOSE Status: NFS4ERR_OLD_STATEID
53049 2019-04-17 12:10:44.818990681  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 53045) CLOSE Status: NFS4ERR_OLD_STATEID
53057 2019-04-17 12:10:44.819085752  10.1.10.191 =E2=86=92 10.1.10.170  NFS
410 V4 Reply (Call In 53052) CLOSE Status: NFS4ERR_OLD_STATEID  ; V4
Reply (Call In 53052) GETATTR
53068 2019-04-17 12:10:44.819315507  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 53065) CLOSE Status: NFS4ERR_OLD_STATEID
53076 2019-04-17 12:10:44.819542785  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 53074) CLOSE Status: NFS4ERR_OLD_STATEID
53672 2019-04-17 12:10:44.908883083  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 53082) CLOSE Status: NFS4ERR_OLD_STATEID
88712 2019-04-17 12:10:46.682247016  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 88711) CLOSE Status: NFS4ERR_OLD_STATEID
88713 2019-04-17 12:10:46.682262932  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 88711) CLOSE Status: NFS4ERR_OLD_STATEID
88725 2019-04-17 12:10:46.683030796  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 88723) CLOSE Status: NFS4ERR_OLD_STATEID
88730 2019-04-17 12:10:46.683209944  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 88729) CLOSE Status: NFS4ERR_OLD_STATEID
93002 2019-04-17 12:10:46.879404035  10.1.10.191 =E2=86=92 10.1.10.170  NFS
898 V4 Reply (Call In 92976) GETATTR  ; V4 Reply (Call In 92990)
GETATTR  ; V4 Reply (Call In 92997) GETATTR  ; V4 Reply (Call In
92999) CLOSE Status: NFS4ERR_OLD_STATEID
93052 2019-04-17 12:10:46.880706310  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 93051) CLOSE Status: NFS4ERR_OLD_STATEID
93056 2019-04-17 12:10:46.880830245  10.1.10.191 =E2=86=92 10.1.10.170  NFS
166 V4 Reply (Call In 93054) CLOSE Status: NFS4ERR_OLD_STATEID
126695 2019-04-17 12:10:48.760521096  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 126567) CLOSE Status: NFS4ERR_OLD_STATEID
126700 2019-04-17 12:10:48.760586900  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
410 V4 Reply (Call In 126568) GETATTR  ; V4 Reply (Call In 126570)
CLOSE Status: NFS4ERR_OLD_STATEID
126704 2019-04-17 12:10:48.760669346  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 126578) CLOSE Status: NFS4ERR_OLD_STATEID
126708 2019-04-17 12:10:48.760786205  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
410 V4 Reply (Call In 126586) GETATTR  ; V4 Reply (Call In 126587)
CLOSE Status: NFS4ERR_OLD_STATEID
226205 2019-04-17 12:10:56.798335876  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
266 V4 Reply (Call In 226170) OPEN Status: NFS4ERR_DELAY  ; V4 Reply
(Call In 226199) TEST_STATEID
226206 2019-04-17 12:10:56.798412890  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 226200) OPEN Status: NFS4ERR_DELAY
253665 2019-04-17 12:10:58.048772590  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
1470 V4 Reply (Call In 253658) READV4 Reply (Call In 253659) CLOSE  ;
V4 Reply (Call In 253661) CLOSE Status: NFS4ERR_OLD_STATEID
253671 2019-04-17 12:10:58.048952402  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 253667) CLOSE Status: NFS4ERR_OLD_STATEID
368579 2019-04-17 12:11:04.582691779  10.1.10.191 =E2=86=92 10.1.10.170  NF=
S
166 V4 Reply (Call In 368574) CLOSE Status: NFS4ERR_BAD_STATEID
^C66792 packets dropped
23 packets captured

There seems to be nothing on any of those clients side of things.

Bruno


On Tue, 16 Apr 2019 at 21:46, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Mon, Apr 15, 2019 at 06:00:56PM +0100, Bruno Santos wrote:
> > We have a debian stretch HPC cluster(#1 SMP Debian 4.9.130-2
> > (2018-10-27)). One of the machines mounts a couple of drives from a
> > Dell compellent system and shares it across a 10GB network to 4
> > different machines.
> >
> > We had the nfs server crashing a few weeks ago because the file-max
> > limit had been reached. At the time we increased the number of file
> > handles it can handle and been monitoring since. We have noticed that
> > the number of entries on that machine keeps increasing though and
> > despite our best efforts we have been unable identify the cause.
> > Anything I can find related to this is from a well known bug in 2011
> > and nothing afterwards. We are assuming this is caused but a leak of
> > file handles on the nfs side but not sure.
> >
> > Does anyone has anyway of figuring out what is causing this? Output
> > from the file-ne, lsof, etc is below.
>
> Off the top of my head, the only idea I have is to try watching
>
>         grep nfsd4 /proc/slabinfo
>
> and see if any of those objects are also leaking.
>
> --b.
>
> >
> > Thank you very much for any help you can provide.
> >
> > Best regards,
> > Bruno Santos
> >
> > :~# while :;do echo "$(date): $(cat /proc/sys/fs/file-nr)";sleep
> > 30;done
> > Mon 15 Apr 17:23:11 BST 2019: 2466176   0       4927726
> > Mon 15 Apr 17:23:41 BST 2019: 2466176   0       4927726
> > Mon 15 Apr 17:24:11 BST 2019: 2466336   0       4927726
> > Mon 15 Apr 17:24:41 BST 2019: 2466240   0       4927726
> > Mon 15 Apr 17:25:11 BST 2019: 2466560   0       4927726
> > Mon 15 Apr 17:25:41 BST 2019: 2466336   0       4927726
> > Mon 15 Apr 17:26:11 BST 2019: 2466400   0       4927726
> > Mon 15 Apr 17:26:41 BST 2019: 2466432   0       4927726
> > Mon 15 Apr 17:27:11 BST 2019: 2466688   0       4927726
> > Mon 15 Apr 17:27:41 BST 2019: 2466624   0       4927726
> > Mon 15 Apr 17:28:11 BST 2019: 2466784   0       4927726
> > Mon 15 Apr 17:28:41 BST 2019: 2466688   0       4927726
> > Mon 15 Apr 17:29:11 BST 2019: 2466816   0       4927726
> > Mon 15 Apr 17:29:42 BST 2019: 2466752   0       4927726
> > Mon 15 Apr 17:30:12 BST 2019: 2467072   0       4927726
> > Mon 15 Apr 17:30:42 BST 2019: 2466880   0       4927726
> >
> > ~# lsof|wc -l
> > 3428
