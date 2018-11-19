Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A7DEC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 19:09:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DBBA62086A
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 19:09:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="effCWUHV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBBA62086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727008AbeKTFeQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 00:34:16 -0500
Received: from mail.kernel.org ([198.145.29.99]:41102 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726070AbeKTFeQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Nov 2018 00:34:16 -0500
Received: from localhost (unknown [77.138.135.184])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 0D34F20831;
        Mon, 19 Nov 2018 19:09:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1542654558;
        bh=qH7Y4P8/TuPWZvWHf5I4LOOo738XutQ7xFg8ZuHAtFs=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=effCWUHVO3xPmYlmsRjQ32f6CBe10ajCwhNa+RM81YRpsZB1QwMjqNuN2tx4rgA56
         mGCEa0iOQSxe3QgsxRum64wiN2DQQP895QqzlWb0TBkZFT+xegyWnv5MV0v3Zl54Jt
         mmdB9xHsgPR9BKRNRIg47YsQVvKuFTaiEuLMvnUY=
Date:   Mon, 19 Nov 2018 21:09:13 +0200
From:   Leon Romanovsky <leon@kernel.org>
To:     Bart Van Assche <bvanassche@acm.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, oulijun@huawei.com, umalhi@cisco.com,
        zhongjiang@huawei.com, venkata.s.dhanalakota@intel.com
Subject: Re: [PATCH v1 1/4] xprtrdma: Remove support for FMR memory
 registration
Message-ID: <20181119190913.GC21715@mtr-leonro.mtl.com>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154551.10832.5498.stgit@manet.1015granger.net>
 <1542644197.185366.50.camel@acm.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="PmA2V3Z32TCmWXqI"
Content-Disposition: inline
In-Reply-To: <1542644197.185366.50.camel@acm.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--PmA2V3Z32TCmWXqI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Nov 19, 2018 at 08:16:37AM -0800, Bart Van Assche wrote:
> On Mon, 2018-11-19 at 10:45 -0500, Chuck Lever wrote:
> > FMR is not supported on most recent RDMA devices. It is also slower
> > and less secure than FRWR. As discussed during the RDMA BoF at LPC
> > 2018, it is time to remove support for FMR in the NFS/RDMA client
> > stack. NFS/RDMA server-side uses either local memory registration or
> > FRWR.  There is no change required there to deprecate FMR.
> >
> > There are a few Infiniband/RoCE devices in the kernel tree that do
> > not support MEM_MGT_EXTENSIONS, and therefore will no longer support
> > client-side NFS/RDMA. These are:
> >
> >  - mthca
> >  - qib
> >  - usnic
> >  - hns (RoCE)
>
> Can someone from Intel comment on how many of their customers rely on the qib
> driver?
>
> Can someone from Cisco comment on how many of their customers rely on the usnic
> driver?
>
> Can someone from Huawei comment on how many of their customers rely on the hns
> driver?
>
> I'm wondering whether I can remove FMR support from the SRP initiator driver.

Bart,

The more accurate question is "how many customers ... use latest,
upstream kernel?"

Thanks

>
> Thanks,
>
> Bart.

--PmA2V3Z32TCmWXqI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJb8wpZAAoJEORje4g2clinRU8P/i4Vp21lG+kr1t6x6oLDbd/H
9HRRsxKJYnsthRd2J95QfUy1w64rpDTs/TlhwSHAVggtzbBUuXsq9IcJmdSxXTOw
DSPz8yjjtRQPI6WLGX7toL6jBHcuM+PeIySzwzeMaIcDmA5ILLQEN8vaWc3m2338
Y26NLxO8CWROSEFuXxUdjTfkCe89tbLanvtMNvSYc1czGSA1uRJ2kB0f1tHQbgXO
REmXXNalHv9hSZklk79lPLQ8fUbYmPp3s/rwezfsO7zTeTZ7YmSzQkmhXaqYi8FA
Wc347MZqB4o8tjdX1HSZp3E3I7KIyGka/ca80pLCnqa1NAvfPVCcxMmAMJs+4PaM
rIS3j2VjQjwjiGuypgqQvl0y0TZ+Caq59VVyqAv50uRoyHQHwR7X/JvgsA5v+3d7
WltuDu4aeupBPnr3uf2fFKyOHTaJP5tyvft1+Oen5xycxbDEO34VecbXPO3JN9AJ
o+054S2uYkebO4qDp6TMt54yOHtHJPjbEuLTgi/oKxPgBMSRt80NqXxBRF47V5Tr
DTOgHopLh/aK4JV9LCUCzz6CSAM7Zn4jJl7VwKVg+SrznYxIUbwyxfjcOCD73VF2
pM+RdiNTYCWpFHkoRWo3AobpoEuh1wGM80PuKIof0+RoTkMLmyuel+enFElILBYS
/VQ5YlcenbnjoQL15eEX
=ve2R
-----END PGP SIGNATURE-----

--PmA2V3Z32TCmWXqI--
