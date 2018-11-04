Return-Path: <SRS0=jFnA=NP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F30EFC32789
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Nov 2018 05:31:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 978D92082E
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Nov 2018 05:31:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 978D92082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728993AbeKDOp0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 4 Nov 2018 09:45:26 -0500
Received: from mx2.suse.de ([195.135.220.15]:39356 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728890AbeKDOpZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 4 Nov 2018 09:45:25 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 142DAAEDC;
        Sun,  4 Nov 2018 05:31:41 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Marc Eshel <eshel@us.ibm.com>,
        Trond Myklebust <trondmy@hammerspace.com>
Date:   Sun, 04 Nov 2018 16:31:29 +1100
Cc:     "bcodding\@redhat.com" <bcodding@redhat.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org,
        "malahal\@gmail.com" <malahal@gmail.com>,
        "mbenjami\@redhat.com" <mbenjami@redhat.com>
Subject: Re: "(deleted)" directories
In-Reply-To: <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com> <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com> <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com> <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com> <CAKOnarkG4tpA7F306hgpk14XNELEFY1gaY7=QY4h6Dr-zSQzRw@mail.gmail.com> <a45a428ad45e5834fa7030088a75275584b13ab2.camel@hammerspace.com> <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com>
Message-ID: <87a7mp1k9a.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 02 2018, Marc Eshel wrote:

> One reason to have different FHs for the same file is that a file can be=
=20
> linked from multiple directories.

This has some based when considering filehandles for non-directories.
However the original problem was with filehandles for directories.....

> Adding the parent inode to the FH help finding the the name of the file b=
y=20
> looking for the file inode in
> the parent directoy.
>

....and directories have a ".." link, obviating the need to store parent
information in the filehandle.

NeilBrown


> Marc.
>
> linux-nfs-owner@vger.kernel.org wrote on 11/02/2018 05:15:42 PM:
>
>> From: Trond Myklebust <trondmy@hammerspace.com>
>> To: "mbenjami@redhat.com" <mbenjami@redhat.com>
>> Cc: "bcodding@redhat.com" <bcodding@redhat.com>, "malahal@gmail.com"
>> <malahal@gmail.com>, "linux-nfs@vger.kernel.org"=20
> <linux-nfs@vger.kernel.org>
>> Date: 11/02/2018 05:15 PM
>> Subject: Re: "(deleted)" directories
>> Sent by: linux-nfs-owner@vger.kernel.org
>>=20
>> On Fri, 2018-11-02 at 18:07 -0400, Matt Benjamin wrote:
>> > It sounds like a pretty good one, that goes to the heart of what a
>> > specification is
>> >=20
>>=20
>> While admittedly it is (still) Dia de los Muertos today, I would think
>> that someone who resurrected a part of the NFSv3 spec that has been
>> unused for the full 23 years of its existence might have some
>> explanation for why they did so?
>>=20
>> IOW: not being of a particularly religious persuasion, I usually want
>> to understand why features are needed rather than having blind faith in
>> the person who wrote the spec.
>>=20
>> > Matt
>> >=20
>> > On Fri, Nov 2, 2018 at 4:26 PM, Trond Myklebust <
>> > trondmy@hammerspace.com> wrote:
>> > > On Fri, 2018-11-02 at 21:24 +0530, Malahal Naineni wrote:
>> > > > Ben, NFSv3 RFC1813.txt states: "If two file handles from the same
>> > > > server are equal, they must refer to the same file, but if
>> > > > they  are
>> > > > not equal, no conclusions can be drawn." Ganesha does return same
>> > > > fileid here (inode).
>> > > >=20
>> > > > In NFSv4, they have introduced "unique_handles" attribute. I
>> > > > don't
>> > > > see
>> > > > Linux NFS client using this at all though.
>> > >=20
>> > > Why does your server need to have multiple filehandles refer to the
>> > > same file, and why do you expect clients to support this?
>> > >=20
>> > > Yes, the spec allows it, but that's not a sufficient reason.
>> > >=20
>> > > > Regards, Malahal.
>> > > > On Fri, Nov 2, 2018 at 4:35 PM Benjamin Coddington <
>> > > > bcodding@redhat.com> wrote:
>> > > > > On 2 Nov 2018, at 1:26, Malahal Naineni wrote:
>> > > > >=20
>> > > > > > Hi All, we are using NFS-Ganesha with Linux NFS clients. The
>> > > > > > client's
>> > > > > > shell reports the following. Based on lsof, the directory is
>> > > > > > marked
>> > > > > > deleted. "cd to ROOT and cd to the same home directory fixes
>> > > > > > the
>> > > > > > issue. The client behaves as though the directory is deleted
>> > > > > > and
>> > > > > > recreated! Our NFS-Ganesha server implementation uses
>> > > > > > multiple
>> > > > > > file
>> > > > > > handles that point to the same object. NFS spec says this
>> > > > > > should
>> > > > > > be
>> > > > > > fine, but Linux NFS seems to be broken in this regard.
>> > > > > > tcpdump
>> > > > > > does
>> > > > > > indicate file handle change (note that all file handles are
>> > > > > > permanent,
>> > > > > > meaning they are valid at the server any time) around this
>> > > > > > issue
>> > > > > > time.
>> > > > > >=20
>> > > > > > "shell-init: error retrieving current directory: getcwd:
>> > > > > > cannot
>> > > > > > access
>> > > > > > parent directories: No such file or directory"
>> > > > > > sh        112544            malahal  cwd       DIR
>> > > > > > 0,67
>> > > > > >      65536   45605209 /home/malahal (deleted)
>> > > > > > (10.120.154.42:/nfs/malahal-export/)
>> > > > > >=20
>> > > > > > Function nfs_prime_dcache() seems to invalidate the dcache
>> > > > > > entry
>> > > > > > if
>> > > > > > nfs_same_file() returns false. nfs_same_file() does seem to
>> > > > > > return
>> > > > > > false with the following change, if I read it correctly, if
>> > > > > > there
>> > > > > > is a
>> > > > > > file handle change. Can this be the source of my issue? It
>> > > > > > seems
>> > > > > > that
>> > > > > > the client should do this only if the file handle is NOT
>> > > > > > valid
>> > > > > > (e.g.
>> > > > > > if it gets ESTALE), right?
>> > > > > >=20
>> > > > > > The following commit seems to assume that the objects are
>> > > > > > different if
>> > > > > > they have different file handles!
>> > > > > > commit 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
>> > > > > > Author: Trond Myklebust <trond.myklebust@primarydata.com>
>> > > > > > Date:   Thu Sep 22 13:38:52 2016 -0400
>> > > > > >=20
>> > > > > >     NFS: Fix inode corruption in nfs_prime_dcache()
>> > > > >=20
>> > > > > My understanding is that for NFSv3 we have to assume that
>> > > > > distinct
>> > > > > filehandles are distinct objects, but maybe I'm wrong about
>> > > > > this.
>> > > > >=20
>> > > > > For NFSv4.x, we can follow the guidance in RFCs 5661 or 7530
>> > > > > section 10.3.4
>> > > > > to determine if the differing filehandles are the same object,
>> > > > > specifically
>> > > > > the fileid recommended attribute needs to be implemented.  Is
>> > > > > Ganesha
>> > > > > returning the same fileid for both filehandles?
>> > > > >=20
>> > > > > Ben
>> > > --
>> > > Trond Myklebust
>> > > CTO, Hammerspace Inc
>> > > 4300 El Camino Real, Suite 105
>> > > Los Altos, CA 94022
>> > > www.hammer.space
>> > >=20
>> > >=20
>> >=20
>> >=20
>> --=20
>> Trond Myklebust
>> CTO, Hammerspace Inc
>> 4300 El Camino Real, Suite 105
>> Los Altos, CA 94022
>> www.hammer.space
>>=20
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlvehDIACgkQOeye3VZi
gbkiAg//ZuwV9orDbRIO/s7q9uWz5XLUBn/uX6UhLKtnIjH2a8pFwAjIZDr02cQh
WnNg6U7xHmKS850w+JVn22q+oZ3ALJsI+mXiAJSnKdxlw6O6EspnVfrFRhRBR623
hVWpKXhJ2R5hDmm8MAqODqd/zwuh5b1hBCBC8LRJnDbdFHl3kr+mH/ghpP9lipS1
dL8GPRg+qRU+Hyh9k3kakF75v+8MgHBIZne9aOYqfgN70ZR2x+xdgwkCYUl/ZIPf
F26Pe9MhtCHkBBVfZ+8ovNxz/ODDXHN3Ba/dLHermRjt0ZkBU//Q+TwA9g0G1HZW
9bqsmJTp25gGc3P3rg5UBqsCc9cWKVnPRKTMprzzR4cJBk6uq46kQgBdCVZC/Eoo
Phy6H+zx5Q5p7UemvONmJIaMM3f5r2Vbc8XEKEuqjOnoTz8Fsow0sgYdtPAcSxiq
zLw9e9QrVe9Z8rD3KyL0MjWAyE9KZv/5ucZoWRDuZCXAuZbvfL3PFfqvFsYI2mWA
XgUkCwJzwO2v3uMsstygHPRvgJ1mZFLq88BdlR16zaJg84vOScBXK3Zoo4/vKSB1
Aygr/8WePI3VI5Iqfau6EoT2RDybqiJsEVQAW55bvpRzxy2LLH3bSC6+8W8G+pC3
yB9qBxTKPGuAPnh25j288PfkGQPVwMQwaR4nkYxwUsNAtHyRn2Q=
=fk4d
-----END PGP SIGNATURE-----
--=-=-=--
