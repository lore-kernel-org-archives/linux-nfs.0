Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:59731 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388AbcAZLeJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2016 06:34:09 -0500
Date: Tue, 26 Jan 2016 19:33:52 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
To: Ilya Dryomov <idryomov@gmail.com>
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
        dm-devel@redhat.com, linux-wireless@vger.kernel.org,
        linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
        linux-bluetooth@vger.kernel.org,
        Ceph Development <ceph-devel@vger.kernel.org>,
        linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
        Lars Ellenberg <drbd-dev@lists.linbit.com>,
        open-iscsi@googlegroups.com
Subject: Re: [PATCH 16/26] libceph: Use skcipher
Message-ID: <20160126113352.GA21159@gondor.apana.org.au>
References: <20160124131021.GA31153@gondor.apana.org.au>
 <E1aNKYy-0008E6-GI@gondolin.me.apana.org.au>
 <CAOi1vP9jmMYHR21UeAO175susZ5V74vcXyoxwayBVSTFHxjhBQ@mail.gmail.com>
 <20160126105455.GA19674@gondor.apana.org.au>
 <CAOi1vP9kB5a-JeZ1PriwyQO0XH4Qh3UKidp==NPvVw-AsL=uqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAOi1vP9kB5a-JeZ1PriwyQO0XH4Qh3UKidp==NPvVw-AsL=uqw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 26, 2016 at 12:29:57PM +0100, Ilya Dryomov wrote:
>
> LGTM.  You want to take it through crypto?

That's probably the easiest route since I'd like to take the first
patch through cryptodev.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
