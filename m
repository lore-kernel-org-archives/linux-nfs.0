Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mtoichi12.ns.itscom.net ([219.110.2.182]:52708 "EHLO
	mtoichi12.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756707Ab1AMNqG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 08:46:06 -0500
From: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Subject: Re: NFS root lockups with -next 20110113
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
In-Reply-To: <676f5c24375e1cc2aa14fe6630ef1324@mail.gmail.com>
References: <20110113120626.GB30351@opensource.wolfsonmicro.com> <8138.1294924927@jrobl> <676f5c24375e1cc2aa14fe6630ef1324@mail.gmail.com>
Date: Thu, 13 Jan 2011 22:45:15 +0900
Message-ID: <8482.1294926315@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Santosh Shilimkar:
> It works. My board booted with NFS with below patch

----------------------------------------

Mark Brown;
> Seems to do the trick:
>
> Tested-by: Mark Brown <broonie@opensource.wolsfonmicro.com>

Thank you so quick tests.
When I post the patch to be mainlined, I will add Tested-by for both of
you. But Nick Piggin may take another approach.


J. R. Okajima

