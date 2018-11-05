Return-Path: <SRS0=wnB3=NQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0657CC32789
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 00:32:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B1F892081D
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 00:32:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1F892081D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729731AbeKEJtb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 5 Nov 2018 04:49:31 -0500
Received: from mx2.suse.de ([195.135.220.15]:55652 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726727AbeKEJtb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Nov 2018 04:49:31 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 642BFAC9C;
        Mon,  5 Nov 2018 00:32:35 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Marc Eshel <eshel@us.ibm.com>
Date:   Mon, 05 Nov 2018 11:32:26 +1100
Cc:     "bcodding\@redhat.com" <bcodding@redhat.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org,
        "malahal\@gmail.com" <malahal@gmail.com>,
        "mbenjami\@redhat.com" <mbenjami@redhat.com>,
        "Trond Myklebust" <trondmy@hammerspace.com>
Subject: Re: "(deleted)" directories
In-Reply-To: <OFEF532072.6C501ABB-ON8825833B.006B930A-8825833B.006CB5D7@notes.na.collabserv.com>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com> <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com> <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com> <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com> <CAKOnarkG4tpA7F306hgpk14XNELEFY1gaY7=QY4h6Dr-zSQzRw@mail.gmail.com> <a45a428ad45e5834fa7030088a75275584b13ab2.camel@hammerspace.com> <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com> <87a7mp1k9a.fsf@notabene.neil.brown.name> <OFEF532072.6C501ABB-ON8825833B.006B930A-8825833B.006CB5D7@notes.na.collabserv.com>
Message-ID: <87sh0gz7mt.fsf@notabene.neil.brown.name>
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

On Sun, Nov 04 2018, Marc Eshel wrote:

> linux-nfs-owner@vger.kernel.org wrote on 11/03/2018 10:31:29 PM:
>
>> From: NeilBrown <neilb@suse.com>
>> To: Marc Eshel <eshel@us.ibm.com>, Trond Myklebust=20
> <trondmy@hammerspace.com>
>> Cc: "bcodding\@redhat.com" <bcodding@redhat.com>, "linux-nfs
>> \@vger.kernel.org" <linux-nfs@vger.kernel.org>, linux-nfs-
>> owner@vger.kernel.org, "malahal\@gmail.com" <malahal@gmail.com>,=20
>> "mbenjami\@redhat.com" <mbenjami@redhat.com>
>> Date: 11/03/2018 10:41 PM
>> Subject: Re: "(deleted)" directories
>> Sent by: linux-nfs-owner@vger.kernel.org
>>=20
>> On Fri, Nov 02 2018, Marc Eshel wrote:
>>=20
>> > One reason to have different FHs for the same file is that a file can=
=20
> be=20
>> > linked from multiple directories.
>>=20
>> This has some based when considering filehandles for non-directories.
>> However the original problem was with filehandles for directories.....
>
> This was just an example of why FH might be different, I don't think we=20
> depend on it for the parent information anymore. Malahal listed some othe=
r=20
> reasons for having different FH for the same file. I believe that Ganesha=
=20
> split the FH to the key portion (the unique id of the file) and some othe=
r=20
> information that is file system dependent. If the NFS client can not=20
> handle the spec definition of FH maybe the spec should be updated to=20
> something like Ganesha does.
> Marc.=20

Do we know exactly why the FH changed in this particular circumstance?
Is there some way to find out?

The NFSv3 spec has been updated - it is called "NFSv4" (now 4.2).  It
says a lot more things about filehandles, but even there, the spec is
only as good as the what has been implemented and tested.  I'm pretty
sure that there are parts of the FH spec that have never been put into
practice - so using them would not be wise (I'm particularly thinking of
volatile file handles).

For better or worse, Linux requires directories to have stable
filehandles for NFSv3.  This requirement is effectively imposed by the
dcache.  If there were some way to reliably check if two filehandles
referred to the same directory, then we could relax that restriction,
but I don't think there is.

I think the other possible reason mentioned for changing the filehandle
is to support migration.  NFSv3 definitely doesn't support migration.
NFSv4 explicitly tries to.

NeilBrown


>
>>=20
>> > Adding the parent inode to the FH help finding the the name of the=20
> file by=20
>> > looking for the file inode in
>> > the parent directoy.
>> >
>>=20
>> ....and directories have a ".." link, obviating the need to store parent
>> information in the filehandle.
>>=20
>> NeilBrown
>>=20
>>=20
>> > Marc.
>> >
>> > linux-nfs-owner@vger.kernel.org wrote on 11/02/2018 05:15:42 PM:
>> >
>> >> From: Trond Myklebust <trondmy@hammerspace.com>
>> >> To: "mbenjami@redhat.com" <mbenjami@redhat.com>
>> >> Cc: "bcodding@redhat.com" <bcodding@redhat.com>, "malahal@gmail.com"
>> >> <malahal@gmail.com>, "linux-nfs@vger.kernel.org"=20
>> > <linux-nfs@vger.kernel.org>
>> >> Date: 11/02/2018 05:15 PM
>> >> Subject: Re: "(deleted)" directories
>> >> Sent by: linux-nfs-owner@vger.kernel.org
>> >>=20
>> >> On Fri, 2018-11-02 at 18:07 -0400, Matt Benjamin wrote:
>> >> > It sounds like a pretty good one, that goes to the heart of what a
>> >> > specification is
>> >> >=20
>> >>=20
>> >> While admittedly it is (still) Dia de los Muertos today, I would=20
> think
>> >> that someone who resurrected a part of the NFSv3 spec that has been
>> >> unused for the full 23 years of its existence might have some
>> >> explanation for why they did so?
>> >>=20
>> >> IOW: not being of a particularly religious persuasion, I usually want
>> >> to understand why features are needed rather than having blind faith=
=20
> in
>> >> the person who wrote the spec.
>> >>=20
>> >> > Matt
>> >> >=20
>> >> > On Fri, Nov 2, 2018 at 4:26 PM, Trond Myklebust <
>> >> > trondmy@hammerspace.com> wrote:
>> >> > > On Fri, 2018-11-02 at 21:24 +0530, Malahal Naineni wrote:
>> >> > > > Ben, NFSv3 RFC1813.txt states: "If two file handles from the=20
> same
>> >> > > > server are equal, they must refer to the same file, but if
>> >> > > > they  are
>> >> > > > not equal, no conclusions can be drawn." Ganesha does return=20
> same
>> >> > > > fileid here (inode).
>> >> > > >=20
>> >> > > > In NFSv4, they have introduced "unique_handles" attribute. I
>> >> > > > don't
>> >> > > > see
>> >> > > > Linux NFS client using this at all though.
>> >> > >=20
>> >> > > Why does your server need to have multiple filehandles refer to=20
> the
>> >> > > same file, and why do you expect clients to support this?
>> >> > >=20
>> >> > > Yes, the spec allows it, but that's not a sufficient reason.
>> >> > >=20
>> >> > > > Regards, Malahal.
>> >> > > > On Fri, Nov 2, 2018 at 4:35 PM Benjamin Coddington <
>> >> > > > bcodding@redhat.com> wrote:
>> >> > > > > On 2 Nov 2018, at 1:26, Malahal Naineni wrote:
>> >> > > > >=20
>> >> > > > > > Hi All, we are using NFS-Ganesha with Linux NFS clients.=20
> The
>> >> > > > > > client's
>> >> > > > > > shell reports the following. Based on lsof, the directory=20
> is
>> >> > > > > > marked
>> >> > > > > > deleted. "cd to ROOT and cd to the same home directory=20
> fixes
>> >> > > > > > the
>> >> > > > > > issue. The client behaves as though the directory is=20
> deleted
>> >> > > > > > and
>> >> > > > > > recreated! Our NFS-Ganesha server implementation uses
>> >> > > > > > multiple
>> >> > > > > > file
>> >> > > > > > handles that point to the same object. NFS spec says this
>> >> > > > > > should
>> >> > > > > > be
>> >> > > > > > fine, but Linux NFS seems to be broken in this regard.
>> >> > > > > > tcpdump
>> >> > > > > > does
>> >> > > > > > indicate file handle change (note that all file handles are
>> >> > > > > > permanent,
>> >> > > > > > meaning they are valid at the server any time) around this
>> >> > > > > > issue
>> >> > > > > > time.
>> >> > > > > >=20
>> >> > > > > > "shell-init: error retrieving current directory: getcwd:
>> >> > > > > > cannot
>> >> > > > > > access
>> >> > > > > > parent directories: No such file or directory"
>> >> > > > > > sh        112544            malahal  cwd       DIR
>> >> > > > > > 0,67
>> >> > > > > >      65536   45605209 /home/malahal (deleted)
>> >> > > > > > (10.120.154.42:/nfs/malahal-export/)
>> >> > > > > >=20
>> >> > > > > > Function nfs_prime_dcache() seems to invalidate the dcache
>> >> > > > > > entry
>> >> > > > > > if
>> >> > > > > > nfs_same_file() returns false. nfs_same_file() does seem to
>> >> > > > > > return
>> >> > > > > > false with the following change, if I read it correctly, if
>> >> > > > > > there
>> >> > > > > > is a
>> >> > > > > > file handle change. Can this be the source of my issue? It
>> >> > > > > > seems
>> >> > > > > > that
>> >> > > > > > the client should do this only if the file handle is NOT
>> >> > > > > > valid
>> >> > > > > > (e.g.
>> >> > > > > > if it gets ESTALE), right?
>> >> > > > > >=20
>> >> > > > > > The following commit seems to assume that the objects are
>> >> > > > > > different if
>> >> > > > > > they have different file handles!
>> >> > > > > > commit 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
>> >> > > > > > Author: Trond Myklebust <trond.myklebust@primarydata.com>
>> >> > > > > > Date:   Thu Sep 22 13:38:52 2016 -0400
>> >> > > > > >=20
>> >> > > > > >     NFS: Fix inode corruption in nfs_prime_dcache()
>> >> > > > >=20
>> >> > > > > My understanding is that for NFSv3 we have to assume that
>> >> > > > > distinct
>> >> > > > > filehandles are distinct objects, but maybe I'm wrong about
>> >> > > > > this.
>> >> > > > >=20
>> >> > > > > For NFSv4.x, we can follow the guidance in RFCs 5661 or 7530
>> >> > > > > section 10.3.4
>> >> > > > > to determine if the differing filehandles are the same=20
> object,
>> >> > > > > specifically
>> >> > > > > the fileid recommended attribute needs to be implemented.  Is
>> >> > > > > Ganesha
>> >> > > > > returning the same fileid for both filehandles?
>> >> > > > >=20
>> >> > > > > Ben
>> >> > > --
>> >> > > Trond Myklebust
>> >> > > CTO, Hammerspace Inc
>> >> > > 4300 El Camino Real, Suite 105
>> >> > > Los Altos, CA 94022
>> >> > > www.hammer.space
>> >> > >=20
>> >> > >=20
>> >> >=20
>> >> >=20
>> >> --=20
>> >> Trond Myklebust
>> >> CTO, Hammerspace Inc
>> >> 4300 El Camino Real, Suite 105
>> >> Los Altos, CA 94022
>> >> www.hammer.space
>> >>=20
>> >>=20
>> [attachment "signature.asc" deleted by Marc Eshel/Almaden/IBM]=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlvfj5oACgkQOeye3VZi
gbl7dw/8DYyfTF8or/xISw93VvlbM1SMwP7bWYHTzxv0Sjwf8BV+cl2GEU5M1rjE
LpI/yJ2LQN4SivpkHt+FUoue1M2JG3hyxS9JyrhlMVD3MjjS01GOWF/4E1aLGd1l
7SyRXfa4jVV5Bu8DnhJyfZP8tjgKtiSZlEd5/Z3xqZsALxeHouFYHE5ppNbRfkeb
BLntZfsNm2yRieRLqe0I5RT4cdpX1obkuBw2QuM18kpla76RtlZaIXMKbCKb6/zH
MbFNSOaOkads/7Yg7gqbVetUTWfBnRjt0U3uxRJu8QNGsIv1Kz1vntJ/JiNTD4cm
t7e6sqK78pkdmEfZ0Otqccot0oTCJ2T+yhQi57Lst7d4q66+IFYi1F8iGJ7RzFq4
eiMS1Y7MzecRlrKKYdt6yGxjN093rMLCKlkKC2/UzwBDKEm1AdqTKKNuFW0FZCCF
cQGBklSbxtUFYWa6vBZGqwi4ETT6T8K1vCPmYOFwR3aPzUloIi6EZz+Wa5eJkp6T
xNfSAE2HNWHHpbSivGevSZ65PuDIirQefGVb8XfmJVh6z0NGcnxs2inmohDa+Cg0
8/2r79EDi5X07XM1jr3wpyzU8kzTPigjcHA0DACpc9PDnwp8NSsY7WKqiSfFN2xA
ZtiygULtHF7EzSPQ24KO8gwinPINf7CWkz0ZJddraxFwhYO0CWQ=
=uAuV
-----END PGP SIGNATURE-----
--=-=-=--
