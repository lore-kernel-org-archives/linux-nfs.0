Return-Path: <SRS0=oebN=QK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 856DAC169C4
	for <linux-nfs@archiver.kernel.org>; Sun,  3 Feb 2019 23:30:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 22F82214DA
	for <linux-nfs@archiver.kernel.org>; Sun,  3 Feb 2019 23:30:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=dilger-ca.20150623.gappssmtp.com header.i=@dilger-ca.20150623.gappssmtp.com header.b="ALxY1UO7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727056AbfBCXaj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 3 Feb 2019 18:30:39 -0500
Received: from mail-pg1-f178.google.com ([209.85.215.178]:44312 "EHLO
        mail-pg1-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726972AbfBCXaj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Feb 2019 18:30:39 -0500
Received: by mail-pg1-f178.google.com with SMTP id y1so1657908pgk.11
        for <linux-nfs@vger.kernel.org>; Sun, 03 Feb 2019 15:30:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dilger-ca.20150623.gappssmtp.com; s=20150623;
        h=from:message-id:mime-version:subject:date:in-reply-to:cc:to
         :references;
        bh=zkEfckH0XX4m3wmQlPLxGf+gsJjGLOBkkeHK9K1arqo=;
        b=ALxY1UO7XQwhzvniil9Cd8c5nLFa25BBzHxNwqVdtgiVE2MGlRjPDRtd+pXOg33eLN
         9qADiKELLZhUAXLCa/42RJkuN93/ahgSn5mJ5vQYmWPCWcjNXUhRuArM0RxnrWotH0Nt
         w1vFRn2dcq+tt39EpFA3jyGwUX6RtRXrCj73Y4TAot5szvqaAVUU8fFOryrSxfZ96bJ3
         jomGLMsgvxmTSCTy4iBbA28uPkQJMmFGrEfF/Cyu4R8LFpEeurk0DfcBFkRRZm9IeQl+
         a0FR24i7/HHtxJLzAr72szfq+uvPbffF1Mp433QU9x/TrG5OwbxZUuS1hquZsIbNgPUh
         lXKA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:message-id:mime-version:subject:date
         :in-reply-to:cc:to:references;
        bh=zkEfckH0XX4m3wmQlPLxGf+gsJjGLOBkkeHK9K1arqo=;
        b=MKcDkskgP7eGdncRZaiHJoVeGlH4zem2IstpAfQ7wmB4qqANjQ/WT56TMHYBFcvEyd
         3frXCzhAGtKtDOL0G0iUyoe8lMYgXfd2s4LdTZYS//wBVpVtelkvZDjqwoc5OMuVkmqh
         NcCK39y7PvHavvt6Np50OdeSe7KDWrITRsyZIQcM0DpgrjmqbL0eevOTvN4b+dJe1wtb
         nmu9WgipHV/1fIxKe1HP+nxKhItKOolROLlsggub2FcOE/t1j55RmUeUABYJzGTuLJAy
         /ADMmGd1G6dkGVyp+dWQpY290fZjCGT0PakEmhijVbMIp0HkbAkJ9R0TE7d4qgX+qwVZ
         AUzA==
X-Gm-Message-State: AJcUukcQvIV8sfplC02/6l5n7s6+APwXHqWWH8CE0U3IMwVBtL+E1DJs
        EI7qT/IiK4LWg6wverSmZQZcIHVCaB8=
X-Google-Smtp-Source: ALg8bN7D3pKCg7cdnP7V2ZopZXM3Bn/ItjwsXVxVcM4mqWhJAglz9LR3SOZI+FFR+/x/wByE99KKiA==
X-Received: by 2002:a62:2702:: with SMTP id n2mr49884557pfn.29.1549236637691;
        Sun, 03 Feb 2019 15:30:37 -0800 (PST)
Received: from cabot.adilger.ext (S0106a84e3fe4b223.cg.shawcable.net. [70.77.216.213])
        by smtp.gmail.com with ESMTPSA id 196sm56764850pfc.77.2019.02.03.15.30.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 15:30:36 -0800 (PST)
From:   Andreas Dilger <adilger@dilger.ca>
Message-Id: <69820EE9-1239-46A1-8887-ECAAA8C8C680@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_7153DB3F-ADE5-46CD-822B-D157EC7D4049";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: NFSv4 i_blocks=0 immediately after creating a file (Was:
 inode_add/set_bytes and i_blocks, dangerous for small files?)
Date:   Sun, 3 Feb 2019 16:30:31 -0700
In-Reply-To: <20190201142830.GA2177@nautica>
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To:     Dominique Martinet <asmadeus@codewreck.org>
References: <20190125140229.GA5119@nautica> <20190201142830.GA2177@nautica>
X-Mailer: Apple Mail (2.3273)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--Apple-Mail=_7153DB3F-ADE5-46CD-822B-D157EC7D4049
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Feb 1, 2019, at 7:28 AM, Dominique Martinet <asmadeus@codewreck.org> =
wrote:
>=20
> Following up on this for NFS as I made a sneaky bug report hard to
> notice, this might be worth having a look:
>=20
> Dominique Martinet wrote on Fri, Jan 25, 2019:
>> [...] There is a small, few seconds window
>> where I can reproduce a similar issue on nfs:
>> $ echo foo > bar; stat -c %b bar; sleep 3; stat -c %b bar
>> 0
>> 8
>> with a 4.14.87 knfsd and 4.19.15-300.fc29 client, nfs 4.2, both =
x86_64,
>> no export option or explicit client option.
>=20
> In other words, the file's i_blocks isn't updated for a short while on
> nfs v4 which might lead to data loss (see previous email for example
> e.g. tar), just create a file and immediately stat to notice.
>=20
>=20
> nfs v3 doesn't exhibit the problem.
>=20
> I also wasn't able to reproduce on the 4.14.87 machine as a and nfs v4
> client so it's likely a semi-recent regression, I could probably =
bissect
> it if really required but I'm sure someone here has some dedicated
> hardware for this better than my laptop :)
>=20
> Feel free to ask if you cannot reproduce and I'll try updating to =
master
> on both client and server just in case.

The "i_blocks =3D=3D 0" causes problems with some software that thinks =
the file
has no data and treats it as sparse.  We work around this in ext4 and =
Lustre
by always reporting i_blocks > 0 for files that have data in them (e.g.
unwritten dirty pages or inline data), see comments nin =
ext4_file_getattr():

        /*
         * If there is inline data in the inode, the inode will normally =
not
         * have data blocks allocated (it may have an external xattr =
block).
         * Report at least one sector for such files, so tools like tar, =
rsync,
         * others don't incorrectly think the file is completely sparse.
         */
        if (unlikely(ext4_has_inline_data(inode)))
                stat->blocks +=3D (stat->size + 511) >> 9;

Cheers, Andreas






--Apple-Mail=_7153DB3F-ADE5-46CD-822B-D157EC7D4049
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAlxXeZcACgkQcqXauRfM
H+CVEQ/+JMJAQBPStJIkZUWG2rFCDW5ikQB6B264SJwkI9KaAGi2HuOnBKf7UJip
C5AMEduPqnirhVQwg4xYCX9W8XXup2mzPXm+/65yCsE5XQ0NQwpZ/i++nLh9zKDB
fR5j9pGS0Kp4+JSDyz0Awbk4Qtu+dsg1ZfRNsnyJCSM1veYaUZtybRm7wOAcvz15
kZW05tYNMRfKuzwemjRz2+tfJXjoqELO8TH4sWBwaxnIdJTZB/z/+aQTlBuXVfUP
MWbCy4lj7Zo9sf6Yaq9UQlmWtj8fcwT5VK0fPQniKRbKzgUFSHZK2wBWrXYzJgOz
KkOis0FQKAem9Hd/PcpUHffUWftYB6PmlGYWtUJeJX95hSuqpv8mFq+ocxORfQCR
gFS5bkgE0Y2SqT7CDYDATMF61ZBBmB9IRnUITMkGTxtjOAeSSUD/Y1u6TaHUalaA
bSuGU/GUuoHGkyE/eW2mrnpE5dHkWYWDaSr60h+c7Yvykd1w1YG9bwlfxAjTFtbe
kRUT6dG73wTB8SWIePkFwgy7eMtwTX9+YH4fKnWWOSAKXU8BV0RjkkM7mbzCOXlG
p/skTIYocj/oWdaaGAsw0LDtZ39j35Z1xYRrv3NH0TiZA6su/9YSUefXxo0Uby5A
ib30gGEQsgYq87qOTMHcB3of2XJtC6r+Nq92SB47kpwRVLIJ05s=
=6LKd
-----END PGP SIGNATURE-----

--Apple-Mail=_7153DB3F-ADE5-46CD-822B-D157EC7D4049--
