From: Peng Tao <bergwolf@gmail.com>
Subject: Re: pnfs-nfs-utils compile errors
Date: Tue, 19 Oct 2010 08:26:03 +0800
Message-ID: <AANLkTikT25FWtb=C0xx=-LZUFT_hOERu0Z1ZxAkVuJN9@mail.gmail.com>
References: <AANLkTin3xF4+QbG8G2pgiUxv9mUMmFOnQOUD2C1ocVrA@mail.gmail.com> <20101018160953.GA19529@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41323 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953Ab0JSA0Y convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Oct 2010 20:26:24 -0400
Received: by vws2 with SMTP id 2so954805vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 18 Oct 2010 17:26:24 -0700 (PDT)
In-Reply-To: <20101018160953.GA19529-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 19, 2010 at 12:09 AM, Jim Rees <rees@umich.edu> wrote:
> Peng Tao wrote:
>
> =C2=A0I fail to compile with pnfs-nfs-utils master branch (commit
> =C2=A048a8d6b13b2f0b720267b1af104addb7426e7cc9). It fails in blkmapd
> =C2=A0directory. Are the files cfg.c and cfg.h missing or deleted?
>
> Yes, they were removed in commit fb9c48c5e1ce2023d3dc2e279537e158130a=
6ba0,
> "blkmapd: get rid of config file and instead examine all block device=
s."
> Maybe you need to do a autogen.sh or make distclean?
Thanks, Jim. After running autogen.sh, I compile successfully.
>

--=20
Thanks,
-Bergwolf
