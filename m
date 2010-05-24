Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62196 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834Ab0EXNnI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 09:43:08 -0400
Received: by gyg13 with SMTP id 13so1475404gyg.19
        for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 06:43:02 -0700 (PDT)
In-Reply-To: <AANLkTinvXyrrqR7YpkLOUAJ890oTBdQCgQuNXD9o3gk-@mail.gmail.com>
References: <1274371457-10003-1-git-send-email-andros@netapp.com>
	 <AANLkTinRG_AhVwFZ6a3GllIHSLa3zBDl0zmVDp3btJhn@mail.gmail.com>
	 <AANLkTikCPFKKMWFVCT3AlIz792q12x3QrH3vDVVePPXN@mail.gmail.com>
	 <AANLkTinvXyrrqR7YpkLOUAJ890oTBdQCgQuNXD9o3gk-@mail.gmail.com>
Date: Mon, 24 May 2010 09:43:02 -0400
Message-ID: <AANLkTikvP2aetI4bF-3ebus1Y91qFV4ahCXfxR_5ZNBN@mail.gmail.com>
Subject: Re: [PATCH 1/1] SQUASHME pnfs-submit: replace layoutcommit_ctx with
	rpc_cred
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Tao Guo <glorioustao@gmail.com>
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 24, 2010 at 2:37 AM, Tao Guo <glorioustao@gmail.com> wrote:
> I see... But what if sync == 1? At that time, data must have already
> been freed, so you should not use data->cred anymore.

Agreed.

Since LAYOUTCOMMIT is not called after close, we can get rid of taking
the reference all together since a reference is taken on OPEN and
dropped on CLOSE.

-->Andy
>
> --
> tao.
>
