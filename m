Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:56354 "EHLO
	mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009AbbCKOw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2015 10:52:56 -0400
Date: Wed, 11 Mar 2015 16:52:49 +0200
From: Baruch Siach <baruch@tkos.co.il>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Peng Tao <tao.peng@primarydata.com>,
        Tom Haynes <Thomas.Haynes@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH] nfs: do not export discarded symbols
Message-ID: <20150311145249.GH2177@tarshish>
References: <3173686.FPJdK9jLbA@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3173686.FPJdK9jLbA@wuerfel>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Arnd,

On Wed, Mar 11, 2015 at 02:37:25PM +0100, Arnd Bergmann wrote:
> The function nfs4_pnfs_v3_ds_connect_unload is exported so it can be
> used by other modules, but is also marked '__exit' and will be
> discarded when built into the kernel, as pointed out by this
> linker error:
> 
> `nfs4_pnfs_v3_ds_connect_unload' referenced in section `___ksymtab_gpl+nfs4_pnfs_v3_ds_connect_unload' of fs/built-in.o: defined in discarded section `.exit.text' of fs/built-in.o
> 
> This removes the __exit annotation to make it safe to call this function.

Should be "do not discard exported symbols" in subject then?

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
