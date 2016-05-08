Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from prv3-mh.provo.novell.com ([137.65.250.26]:46565 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbcEHWSj (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Sun, 8 May 2016 18:18:39 -0400
From: NeilBrown <nfbrown@novell.com>
To: Richard Weinberger <richard@nod.at>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Date: Mon, 09 May 2016 08:18:22 +1000
Cc: "linux-mtd\@lists.infradead.org" <linux-mtd@lists.infradead.org>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        Christoph Hellwig <hch@infradead.org>
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Reconsidering exportable UBIFS
In-Reply-To: <5702E7F5.1050807@nod.at>
References: <5702E7F5.1050807@nod.at>
Message-ID: <871t5curbl.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


(added linux-nfs@vger.kernel.org)

On Tue, Apr 05 2016, Richard Weinberger wrote:

> Hi!
>
> Currently UBIFS is not exportable.
> I'm not sure whether it is completely impossible or if I just miss a detail.
> So I've some questions.
>
> Documentation/filesystems/nfs/Exporting states that the only required function
> is fh_to_dentry().
> This function should on UBIFS be implementable using generic_fh_to_dentry().
> While UBIFS reuses in theory inode numbers we can ignore i_generation as
> the flash chip is long dead before we start reusing inodes. Same as for JFFS2.
> But the same document states also that fh_to_parent() and get_parent() are optional
> but strongly recommended.
> What does this mean? Will NFS work but puppies die and turn into
> zombies?

Not puppies, just kittens.

If you don't provide these functions, then exporting with
"subtree_check" won't work.  That is no great loss except that people
might find the failure confusing.


>
> Implementing get_parent() is a little unpleasant.
> UBIFS's on-flash layout does not support querying the parent.
> We could change UBIFS's struct ubifs_ino_node, but I'd change the
> on-flash layout only as last resort.
>
> The biggest problem I see is that UBIFS does not really support telldir()
> and seekdir().
> Directory offsets in UBIFS are plain hash values, so telldir()/seekdir() won't
> correctly work if UBIFS faces hash collisions.
> Currently UBIFS implements a hack which stores the UBIFS dent object into
> file->private_data such that consecutive readdir()s are guaranteed to work.
> A comment on UBIFS's readdir states:
>  * This means that UBIFS cannot support NFS which requires full
>  * 'seekdir()'/'telldir()' support.
>
> Is this still true? Maybe we can have NFS even if it is not perfect in
> terms of performance.

How big are your hashes?
ext3 messed up their readdir/telldir design too so they don't have
guaranteed unique keys.
When using 32bit hashes you can definitely get problems with
collisions.  I have not heard of problems with 64bit hashes.

I may have the details slightly wrong, but as I recall non-uniqueness of
cookies only causes a problem when the last cookie returned in a READDIR
reply matches the first cookie returned in reply to the next readdir.
So non-uniqueness is only a problem when it aligns badly.

NeilBrown


>
> Artem, did I miss another show stopper? :-)
>
> Thanks,
> //richard
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXL7suAAoJEDnsnt1WYoG5X/QQAIVeH0iJAx/zp0rWVKI3VHYx
4JrmAsj7Lz1yasRGhDOlh/J+zJ/wYszjaj/v2z8uXmeib5xmuBlRGMSW2MY831hM
dXL8co5QQs73YYAieifn6F8yP1w8QoQE8hp0jlkEnSMjZbTnd2V4WPkCdMz8Lwbe
vcSzvQyvPrxifj/e8wD0kwRsIYl9re8dbz6lqYYpxQPceicWu8SiQgKzCajYddqF
2FgkVMOZOidanxr1BrF9ZGYQfb/vmnmvXX0FMMZB0/JQQJ805eytQlDJflYCflTJ
6NX+5Pya+2625tUPwe8wqsblZAhu2dHRma9t69LNNWSsOW8BbJZPtTinqdzITFJS
TJoS8aC6Alz9UCVnXsaFiS8Mwcsgm/+Ypq0Wg/Cnh8C796EbHv0jiNFiMkRRqsvF
8CHNbBmOdk/heHGCBXHDIc4/oCN4Ko+xd9pAEOLz6oc+mfxBit/XzRS1Ewx0haUB
AW62a7jC98hTON8VYeM+Kr9tAhrrsT/vkAujSF3HX1nBDQdZx+cr7LXOa68mmM6j
xF5NnM10Ehfc4jsL083SweJok8HlOxbdm7qAsoqHGOJoxFWvGJOSL7tHEH0B32KD
aaj9yfo66xnNLdZW9fKP9ev1y6y4cvHBdJkdpkspKopG/H1npAGJ50OzTgsg1f2w
Tf2WtaU5t4/9/5+l3P0U
=/iAe
-----END PGP SIGNATURE-----
--=-=-=--
