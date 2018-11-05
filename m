Return-Path: <SRS0=wnB3=NQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D015CC0044C
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 23:49:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 86E4820827
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 23:49:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86E4820827
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725796AbeKFJLz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Nov 2018 04:11:55 -0500
Received: from mx2.suse.de ([195.135.220.15]:57556 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725760AbeKFJLz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Nov 2018 04:11:55 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 316C1B176;
        Mon,  5 Nov 2018 23:49:37 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "malahal\@gmail.com" <malahal@gmail.com>
Date:   Tue, 06 Nov 2018 10:49:29 +1100
Cc:     "bcodding\@redhat.com" <bcodding@redhat.com>,
        "mbenjami\@redhat.com" <mbenjami@redhat.com>,
        "eshel\@us.ibm.com" <eshel@us.ibm.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: "(deleted)" directories
In-Reply-To: <65e6206915d686909ebe603f95f86fa4c88b3285.camel@hammerspace.com>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com> <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com> <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com> <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com> <CAKOnarkG4tpA7F306hgpk14XNELEFY1gaY7=QY4h6Dr-zSQzRw@mail.gmail.com> <a45a428ad45e5834fa7030088a75275584b13ab2.camel@hammerspace.com> <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com> <87a7mp1k9a.fsf@notabene.neil.brown.name> <OFEF532072.6C501ABB-ON8825833B.006B930A-8825833B.006CB5D7@notes.na.collabserv.com> <87sh0gz7mt.fsf@notabene.neil.brown.name> <CAGD+tkwz_HvBmjwQgLbftf6qU-pL75SJ6a1zq_P239eXMOUDgg@mail.gmail.com> <87muqoyutl.fsf@notabene.neil.brown.name> <CAGD+tkw5QqZet6n82NavneWK8-_uHo24muxYPj+gqrY=tbk2yA@mail.gmail.com> <65e6206915d686909ebe603f95f86fa4c88b3285.camel@hammerspace.com>
Message-ID: <878t27ytiu.fsf@notabene.neil.brown.name>
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

On Mon, Nov 05 2018, Trond Myklebust wrote:

> On Mon, 2018-11-05 at 13:10 +0530, Malahal Naineni wrote:
>> > > My reading of section 10.3.4 of RFC7530 suggests that the client
>> > > should
>> generally compare fsid and fileid to see if two different filehandles
>> refer to
>> the same object or not.
>
> Except that is wrong. As I already said in my previous email, there are
> servers out there in the field that are happy to serve up snapshots
> that have the exact same fsid and fileid as the original files. NetApp
> will for instance happily do this by default unless you explicitly
> configure it not to.
>
>>=20
>> Section 10.3.4 is for files only correct? The issue here is for
>> directories. Also, Trond clearly pointed that Linux breaks section
>> 10.3.4 from his email stating "We treat always different filehandles
>> as if they refer to different
>> files. It has long been the case that snapshots from several vendors
>> are encoded to look like the same file (same fileid + same  fsid) and
>> differing only by filehandle. If we were to try to consolidate those
>> inodes we would end up corrupting application data."
>>=20
>> We don't respect either NFSv3 or NFSv4 RFCs in this regard!
>
> While RFC7530 does have section 10.3.4 that describes "a reliable
> method to determine whether two distinct filehandles represent distinct
> objects", as long as server vendors are shipping product that violates
> it, then that entire section is a moot point.

Ignoring the spec in order to support broken servers wouldn't be my
first choice, but you do have a point.
However, this is only an issue (as far as I know) in a specific
circumstance that would not (I think) affect those servers.

If we do a lookup of a name that we already have in the dcache, and we
get a filehandle which is different from the cached inode, but has the
same fsid/fileid as the cached inode, then it isn't going to be the same
file in a different snapshot.  In that case it might be reasonable to
treat it as the same file, at least when it is a directory.
i.e. same ( fsid, fileid, type, name) means same object.

Maybe that would be too messy to implement, but it seems to be a
possible balance between compliance and safety.  It should stop
directories from becoming "(deleted)" but shouldn't risk data
corruption.


Thanks,
NeilBrown


>
> BTW: Note also how the same section reminds server vendors that "For
> NFSv3 clients, the typical practice has been to assume for the purpose
> of caching that distinct filehandles represent distinct file system
> objects."
>
> However, even if a client were to follow Section 10.3.4, then Section
> 9.1.4 states that any open/lock/delegation stateid is associated with a
> _single filehandle_, and that the lock state it carries is not allowed
> to be consolidated per file or fileid. See also Section 9.11, which
> more explicitly describes how to treat the multiple filehandle case.
>
> So while NFSv4 theoretically allows for the behaviour you are asking
> for, it is not particularly practical to implement, and as I said, the
> entire Section 10.3.4 is undermined by existing server implementations.
>
>> Regards, Malahal.
>>=20
>>=20
>> Regards, Malahal.
>> On Mon, Nov 5, 2018 at 10:39 AM NeilBrown <neilb@suse.com> wrote:
>> > On Mon, Nov 05 2018, Malahal Naineni wrote:
>> >=20
>> > > > Do we know exactly why the FH changed in this particular
>> > > > circumstance?
>> > >=20
>> > > In this instance, this is due to a code bug but obviously, there
>> > > are
>> > > legitimate cases where this occur with Ganesha.
>> >=20
>> > Good to know that bug has been found, and presumably fixed.
>> > It is not obvious to me that there are any such legitimate cases
>> > for
>> > directories.
>> >=20
>> > > > (I'm particularly thinking of volatile file handles).
>> > >=20
>> > > NFS4 RFC has "unique filehandles" concept as well. Linux NFS
>> > > client
>> > > doesn't seem to use "unique filehandles" attribute as well.
>> >=20
>> > A client doesn't need to use that attribute.
>> > My reading of section 10.3.4 of RFC7530 suggests that the client
>> > should
>> > generally compare fsid and fileid to see if two different
>> > filehandles refer to
>> > the same object or not.
>> > If unique_handles is known to be set for a given fsid, then
>> > different
>> > filehandles imply different files, without bothering to check the
>> > fileid.
>> > So the use of unique_handles is an optimization.
>> >=20
>> > I haven't looked at the Linux/NFS code to see if it conforms to
>> > 10.3.4.
>> >=20
>> > NeilBrown
>> >=20
>> >=20
>> > > On Mon, Nov 5, 2018 at 6:02 AM NeilBrown <neilb@suse.com> wrote:
>> > > > On Sun, Nov 04 2018, Marc Eshel wrote:
>> > > >=20
>> > > > > linux-nfs-owner@vger.kernel.org wrote on 11/03/2018 10:31:29
>> > > > > PM:
>> > > > >=20
>> > > > > > From: NeilBrown <neilb@suse.com>
>> > > > > > To: Marc Eshel <eshel@us.ibm.com>, Trond Myklebust
>> > > > > <trondmy@hammerspace.com>
>> > > > > > Cc: "bcodding\@redhat.com" <bcodding@redhat.com>, "linux-
>> > > > > > nfs
>> > > > > > \@vger.kernel.org" <linux-nfs@vger.kernel.org>, linux-nfs-
>> > > > > > owner@vger.kernel.org, "malahal\@gmail.com" <
>> > > > > > malahal@gmail.com>,
>> > > > > > "mbenjami\@redhat.com" <mbenjami@redhat.com>
>> > > > > > Date: 11/03/2018 10:41 PM
>> > > > > > Subject: Re: "(deleted)" directories
>> > > > > > Sent by: linux-nfs-owner@vger.kernel.org
>> > > > > >=20
>> > > > > > On Fri, Nov 02 2018, Marc Eshel wrote:
>> > > > > >=20
>> > > > > > > One reason to have different FHs for the same file is
>> > > > > > > that a file can
>> > > > > be
>> > > > > > > linked from multiple directories.
>> > > > > >=20
>> > > > > > This has some based when considering filehandles for non-
>> > > > > > directories.
>> > > > > > However the original problem was with filehandles for
>> > > > > > directories.....
>> > > > >=20
>> > > > > This was just an example of why FH might be different, I
>> > > > > don't think we
>> > > > > depend on it for the parent information anymore. Malahal
>> > > > > listed some other
>> > > > > reasons for having different FH for the same file. I believe
>> > > > > that Ganesha
>> > > > > split the FH to the key portion (the unique id of the file)
>> > > > > and some other
>> > > > > information that is file system dependent. If the NFS client
>> > > > > can not
>> > > > > handle the spec definition of FH maybe the spec should be
>> > > > > updated to
>> > > > > something like Ganesha does.
>> > > > > Marc.
>> > > >=20
>> > > > Do we know exactly why the FH changed in this particular
>> > > > circumstance?
>> > > > Is there some way to find out?
>> > > >=20
>> > > > The NFSv3 spec has been updated - it is called "NFSv4" (now
>> > > > 4.2).  It
>> > > > says a lot more things about filehandles, but even there, the
>> > > > spec is
>> > > > only as good as the what has been implemented and tested.  I'm
>> > > > pretty
>> > > > sure that there are parts of the FH spec that have never been
>> > > > put into
>> > > > practice - so using them would not be wise (I'm particularly
>> > > > thinking of
>> > > > volatile file handles).
>> > > >=20
>> > > > For better or worse, Linux requires directories to have stable
>> > > > filehandles for NFSv3.  This requirement is effectively imposed
>> > > > by the
>> > > > dcache.  If there were some way to reliably check if two
>> > > > filehandles
>> > > > referred to the same directory, then we could relax that
>> > > > restriction,
>> > > > but I don't think there is.
>> > > >=20
>> > > > I think the other possible reason mentioned for changing the
>> > > > filehandle
>> > > > is to support migration.  NFSv3 definitely doesn't support
>> > > > migration.
>> > > > NFSv4 explicitly tries to.
>> > > >=20
>> > > > NeilBrown
>> > > >=20
>> > > >=20
>> > > > > > > Adding the parent inode to the FH help finding the the
>> > > > > > > name of the
>> > > > > file by
>> > > > > > > looking for the file inode in
>> > > > > > > the parent directoy.
>> > > > > > >=20
>> > > > > >=20
>> > > > > > ....and directories have a ".." link, obviating the need to
>> > > > > > store parent
>> > > > > > information in the filehandle.
>> > > > > >=20
>> > > > > > NeilBrown
>> > > > > >=20
>> > > > > >=20
>> > > > > > > Marc.
>> > > > > > >=20
>> > > > > > > linux-nfs-owner@vger.kernel.org wrote on 11/02/2018
>> > > > > > > 05:15:42 PM:
>> > > > > > >=20
>> > > > > > > > From: Trond Myklebust <trondmy@hammerspace.com>
>> > > > > > > > To: "mbenjami@redhat.com" <mbenjami@redhat.com>
>> > > > > > > > Cc: "bcodding@redhat.com" <bcodding@redhat.com>, "
>> > > > > > > > malahal@gmail.com"
>> > > > > > > > <malahal@gmail.com>, "linux-nfs@vger.kernel.org"
>> > > > > > > <linux-nfs@vger.kernel.org>
>> > > > > > > > Date: 11/02/2018 05:15 PM
>> > > > > > > > Subject: Re: "(deleted)" directories
>> > > > > > > > Sent by: linux-nfs-owner@vger.kernel.org
>> > > > > > > >=20
>> > > > > > > > On Fri, 2018-11-02 at 18:07 -0400, Matt Benjamin wrote:
>> > > > > > > > > It sounds like a pretty good one, that goes to the
>> > > > > > > > > heart of what a
>> > > > > > > > > specification is
>> > > > > > > > >=20
>> > > > > > > >=20
>> > > > > > > > While admittedly it is (still) Dia de los Muertos
>> > > > > > > > today, I would
>> > > > > think
>> > > > > > > > that someone who resurrected a part of the NFSv3 spec
>> > > > > > > > that has been
>> > > > > > > > unused for the full 23 years of its existence might
>> > > > > > > > have some
>> > > > > > > > explanation for why they did so?
>> > > > > > > >=20
>> > > > > > > > IOW: not being of a particularly religious persuasion,
>> > > > > > > > I usually want
>> > > > > > > > to understand why features are needed rather than
>> > > > > > > > having blind faith
>> > > > > in
>> > > > > > > > the person who wrote the spec.
>> > > > > > > >=20
>> > > > > > > > > Matt
>> > > > > > > > >=20
>> > > > > > > > > On Fri, Nov 2, 2018 at 4:26 PM, Trond Myklebust <
>> > > > > > > > > trondmy@hammerspace.com> wrote:
>> > > > > > > > > > On Fri, 2018-11-02 at 21:24 +0530, Malahal Naineni
>> > > > > > > > > > wrote:
>> > > > > > > > > > > Ben, NFSv3 RFC1813.txt states: "If two file
>> > > > > > > > > > > handles from the
>> > > > > same
>> > > > > > > > > > > server are equal, they must refer to the same
>> > > > > > > > > > > file, but if
>> > > > > > > > > > > they  are
>> > > > > > > > > > > not equal, no conclusions can be drawn." Ganesha
>> > > > > > > > > > > does return
>> > > > > same
>> > > > > > > > > > > fileid here (inode).
>> > > > > > > > > > >=20
>> > > > > > > > > > > In NFSv4, they have introduced "unique_handles"
>> > > > > > > > > > > attribute. I
>> > > > > > > > > > > don't
>> > > > > > > > > > > see
>> > > > > > > > > > > Linux NFS client using this at all though.
>> > > > > > > > > >=20
>> > > > > > > > > > Why does your server need to have multiple
>> > > > > > > > > > filehandles refer to
>> > > > > the
>> > > > > > > > > > same file, and why do you expect clients to support
>> > > > > > > > > > this?
>> > > > > > > > > >=20
>> > > > > > > > > > Yes, the spec allows it, but that's not a
>> > > > > > > > > > sufficient reason.
>> > > > > > > > > >=20
>> > > > > > > > > > > Regards, Malahal.
>> > > > > > > > > > > On Fri, Nov 2, 2018 at 4:35 PM Benjamin
>> > > > > > > > > > > Coddington <
>> > > > > > > > > > > bcodding@redhat.com> wrote:
>> > > > > > > > > > > > On 2 Nov 2018, at 1:26, Malahal Naineni wrote:
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > > Hi All, we are using NFS-Ganesha with Linux
>> > > > > > > > > > > > > NFS clients.
>> > > > > The
>> > > > > > > > > > > > > client's
>> > > > > > > > > > > > > shell reports the following. Based on lsof,
>> > > > > > > > > > > > > the directory
>> > > > > is
>> > > > > > > > > > > > > marked
>> > > > > > > > > > > > > deleted. "cd to ROOT and cd to the same home
>> > > > > > > > > > > > > directory
>> > > > > fixes
>> > > > > > > > > > > > > the
>> > > > > > > > > > > > > issue. The client behaves as though the
>> > > > > > > > > > > > > directory is
>> > > > > deleted
>> > > > > > > > > > > > > and
>> > > > > > > > > > > > > recreated! Our NFS-Ganesha server
>> > > > > > > > > > > > > implementation uses
>> > > > > > > > > > > > > multiple
>> > > > > > > > > > > > > file
>> > > > > > > > > > > > > handles that point to the same object. NFS
>> > > > > > > > > > > > > spec says this
>> > > > > > > > > > > > > should
>> > > > > > > > > > > > > be
>> > > > > > > > > > > > > fine, but Linux NFS seems to be broken in
>> > > > > > > > > > > > > this regard.
>> > > > > > > > > > > > > tcpdump
>> > > > > > > > > > > > > does
>> > > > > > > > > > > > > indicate file handle change (note that all
>> > > > > > > > > > > > > file handles are
>> > > > > > > > > > > > > permanent,
>> > > > > > > > > > > > > meaning they are valid at the server any
>> > > > > > > > > > > > > time) around this
>> > > > > > > > > > > > > issue
>> > > > > > > > > > > > > time.
>> > > > > > > > > > > > >=20
>> > > > > > > > > > > > > "shell-init: error retrieving current
>> > > > > > > > > > > > > directory: getcwd:
>> > > > > > > > > > > > > cannot
>> > > > > > > > > > > > > access
>> > > > > > > > > > > > > parent directories: No such file or
>> > > > > > > > > > > > > directory"
>> > > > > > > > > > > > > sh        112544            malahal  cwd=20=20=
=20=20=20
>> > > > > > > > > > > > >   DIR
>> > > > > > > > > > > > > 0,67
>> > > > > > > > > > > > >      65536   45605209 /home/malahal (deleted)
>> > > > > > > > > > > > > (10.120.154.42:/nfs/malahal-export/)
>> > > > > > > > > > > > >=20
>> > > > > > > > > > > > > Function nfs_prime_dcache() seems to
>> > > > > > > > > > > > > invalidate the dcache
>> > > > > > > > > > > > > entry
>> > > > > > > > > > > > > if
>> > > > > > > > > > > > > nfs_same_file() returns false.
>> > > > > > > > > > > > > nfs_same_file() does seem to
>> > > > > > > > > > > > > return
>> > > > > > > > > > > > > false with the following change, if I read it
>> > > > > > > > > > > > > correctly, if
>> > > > > > > > > > > > > there
>> > > > > > > > > > > > > is a
>> > > > > > > > > > > > > file handle change. Can this be the source of
>> > > > > > > > > > > > > my issue? It
>> > > > > > > > > > > > > seems
>> > > > > > > > > > > > > that
>> > > > > > > > > > > > > the client should do this only if the file
>> > > > > > > > > > > > > handle is NOT
>> > > > > > > > > > > > > valid
>> > > > > > > > > > > > > (e.g.
>> > > > > > > > > > > > > if it gets ESTALE), right?
>> > > > > > > > > > > > >=20
>> > > > > > > > > > > > > The following commit seems to assume that the
>> > > > > > > > > > > > > objects are
>> > > > > > > > > > > > > different if
>> > > > > > > > > > > > > they have different file handles!
>> > > > > > > > > > > > > commit
>> > > > > > > > > > > > > 7dc72d5f7a0ec97a53e126c46e2cbd2560757955
>> > > > > > > > > > > > > Author: Trond Myklebust <
>> > > > > > > > > > > > > trond.myklebust@primarydata.com>
>> > > > > > > > > > > > > Date:   Thu Sep 22 13:38:52 2016 -0400
>> > > > > > > > > > > > >=20
>> > > > > > > > > > > > >     NFS: Fix inode corruption in
>> > > > > > > > > > > > > nfs_prime_dcache()
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > My understanding is that for NFSv3 we have to
>> > > > > > > > > > > > assume that
>> > > > > > > > > > > > distinct
>> > > > > > > > > > > > filehandles are distinct objects, but maybe I'm
>> > > > > > > > > > > > wrong about
>> > > > > > > > > > > > this.
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > For NFSv4.x, we can follow the guidance in RFCs
>> > > > > > > > > > > > 5661 or 7530
>> > > > > > > > > > > > section 10.3.4
>> > > > > > > > > > > > to determine if the differing filehandles are
>> > > > > > > > > > > > the same
>> > > > > object,
>> > > > > > > > > > > > specifically
>> > > > > > > > > > > > the fileid recommended attribute needs to be
>> > > > > > > > > > > > implemented.  Is
>> > > > > > > > > > > > Ganesha
>> > > > > > > > > > > > returning the same fileid for both filehandles?
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > Ben
>> > > > > > > > > > --
>> > > > > > > > > > Trond Myklebust
>> > > > > > > > > > CTO, Hammerspace Inc
>> > > > > > > > > > 4300 El Camino Real, Suite 105
>> > > > > > > > > > Los Altos, CA 94022
>> > > > > > > > > > www.hammer.space
>> > > > > > > > > >=20
>> > > > > > > > > >=20
>> > > > > > > > --
>> > > > > > > > Trond Myklebust
>> > > > > > > > CTO, Hammerspace Inc
>> > > > > > > > 4300 El Camino Real, Suite 105
>> > > > > > > > Los Altos, CA 94022
>> > > > > > > > www.hammer.space
>> > > > > > > >=20
>> > > > > > > >=20
>> > > > > > [attachment "signature.asc" deleted by Marc
>> > > > > > Eshel/Almaden/IBM]
> Trond Myklebust
> CTO, Hammerspace Inc
> 4300 El Camino Real, Suite 105
> Los Altos, CA 94022
> www.hammer.space
>
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlvg1woACgkQOeye3VZi
gbkejQ/7BG3YTDOEIZB0nzpfNRpvthSFrahVZQ1qs/bhGEVUm82biyd+m1cq3Rzl
X6WNAqI/zs9VlUfUvIeeX6rf1wakU/Rgvfi2oGIEib+LYna73YRk+4nNg5ddv9h0
vxtPtC/Mo5w+uCShN2Q+I0nRPlY6k4BnydXWvk/rrfCbysedojvWi6b1lqcemwoi
HeT//OT+AN4G1QPVBwmbFtxut47MYRACuVPcExtDNrL4NWDix+DZiJjhHXZhRQ1y
VgdAST8DFy+7eFii+a1xNq5cGWaRflwZsNcBv+kPNAyHfYljMWKZh3+MXkbdZPI0
U5fM9gzVSNg5fc8edT1OJ2myBo6Py1ThGDoMquIP1rEANLhTxfytsCmB52lRxg8L
fTVd19vwxHV8rTBNAK6va6yJ1woRyK4fCJHRM8Zc9m78jo7EnASYA/vSJk8cuSpO
nt4aEgiN2/eFK38L2+keEghfgO8UGKXZIlJOEnvRKMzAZ3t0n+8U8TYnkhiK+vth
kWchFem4ZoVOn+asTFYCSV6HU0eTs26Jql3aV4OdaUAvPiSoeZhWb73HMrfkF1T3
jMiM4fiCP2h2uy1MH8s2P3crfaQkX2W6mDtm/vEBmUTGtTVH4AiqZu9xAAKyK3yi
juFjruuJ3duFhzLrCn3iegi70oudmPAaJluTD7QkLb+hANVa2us=
=Tw8l
-----END PGP SIGNATURE-----
--=-=-=--
