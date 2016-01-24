Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:58116 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbcAXNjy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:39:54 -0500
Date: Sun, 24 Jan 2016 21:39:39 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        dm-devel@redhat.com, linux-wireless@vger.kernel.org,
        linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com
Subject: Re: [PATCH 1/26] block: cryptoloop - Use new skcipher interface
Message-ID: <20160124133939.GA32106@gondor.apana.org.au>
References: <E1aNKWU-0008A9-Dx@gondolin.me.apana.org.au>
 <201601242148.Yk7531Nh%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201601242148.Yk7531Nh%fengguang.wu@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 24, 2016 at 09:37:33PM +0800, kbuild test robot wrote:
> 
> [auto build test ERROR on net/master]
> [also build test ERROR on v4.4 next-20160122]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

These patches depend on the two helpers that I posted yesterday
so unfortunately we'll be getting quite a few build errors from
the bot.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
