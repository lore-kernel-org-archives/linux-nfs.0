Return-Path: <SRS0=Gfnv=W6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C984EC3A5A2
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Sep 2019 18:09:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7328322CF8
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Sep 2019 18:09:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=stwm.de header.i=@stwm.de header.b="oUfKGroB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727624AbfICSJp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 Sep 2019 14:09:45 -0400
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:33810 "EHLO
        email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727352AbfICSJp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Sep 2019 14:09:45 -0400
X-Greylist: delayed 413 seconds by postgrey-1.27 at vger.kernel.org; Tue, 03 Sep 2019 14:09:44 EDT
Received: from mailhub.studentenwerk.mhn.de (mailhub.studentenwerk.mhn.de [127.0.0.1])
        by email.studentenwerk.mhn.de (Postfix) with ESMTP id 46NFDB3KQbzRhSl;
        Tue,  3 Sep 2019 20:02:50 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=stwm.de;
        s=stwm-20170627; t=1567533770;
        bh=cDBU6ESHTAM3Zu+XZG0ThiswLTZCCx+T14baC5kz5RE=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=oUfKGroBMvZr9bWL6bvu2wHF6cW24EWEK2kkcpSnfuO4PJqhNs/GyHai4u8Ws6Jww
         83xWPkP3NWu/+5KIbnIH5RysurPrZ6Cqsnvp0RDeJtwwaii/64f8FFLtjJJCVxYFlW
         J2R44xg9DCGklrBW8YIzgsUNjBl2hQswz0qiaV2OXm5d+MKfMaMqFhJ9AEcl1Ybdcq
         BZ0TbdsO0dV6ddXrZDa0+w79j1mDRzO6MzEgdrSjCSacDmCIE+TCfpwv3hCXUHLEEX
         EWW43y0dua6vMakLM8iwCOPZ+yxbUD6CX3ruDFA0dyjC2S8X6WqU93iF/E0KsVNBAm
         aYiCkmbE3DmJw==
From:   Wolfgang Walter <linux@stwm.de>
To:     Jason L Tibbitts III <tibbs@math.uh.edu>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org, km@cm4all.com,
        linux-kernel@vger.kernel.org
Subject: Re: Regression in 5.1.20: Reading long directory fails
Date:   Tue, 03 Sep 2019 20:02:50 +0200
Message-ID: <4418877.15LTP4gqqJ@stwm.de>
User-Agent: KMail/4.14.3 (Linux/5.0.6-050006-generic; KDE/4.14.13; x86_64; ; )
In-Reply-To: <ufa5zm9s7kz.fsf@epithumia.math.uh.edu>
References: <ufak1bhyuew.fsf@epithumia.math.uh.edu> <ufay2zduosz.fsf@epithumia.math.uh.edu> <ufa5zm9s7kz.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Am Dienstag, 3. September 2019, 10:49:48 schrieb Jason L Tibbitts III:
> >>>>> "JLT" =3D=3D Jason L Tibbitts <tibbs@math.uh.edu> writes:
> JLT> Certainly a server reboot, or maybe even just
> JLT> unmounting and remounting the filesystem or copying the data to
> JLT> another filesystem would tell me that.  In any case, as soon as =
I
> JLT> am able to mess with that server, I'll know more.
>=20
> Rebooting the server did not make any difference, and now more users =
are
> seeing the problem.  At this point I'm in a state where NFS simply is=
n't
> reliable at all, and I'm not sure what to do.  If Centos 8 were out,
> I'd work on moving to that just so that the server was a little more
> modern.  (Currently the server is Centos 7.)  I guess I could try usi=
ng
> Fedora, or installing one of the upstream kernels, just in case this =
has
> to do with some interaction between the client and the old RHEL7 kern=
el.
>=20
> I do have a packet capture of a directory listing that fails with EIO=
,
> but I'm not sure if it's safe to simply post it, and I'm not sure wha=
t
> tshark options would be useful in decoding it.
>=20
> I do know that I can rsync one of the problematic directories to a
> different server (running the same kernel) and it doesn't have the sa=
me
> problem.  What I'll try next is rsyncing to a different filesystem on=

> the same server, but again I'll have to wait until people log off to =
do
> proper testing.
>=20
>  - J<

What filesystem do you use on the server? xfs? If yes, does it use 64bi=
t=20
inodes (or started to use them)? Do you set a fsid when you export the=20=

filesystem?

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
