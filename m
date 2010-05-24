From: Tao Guo <glorioustao@gmail.com>
Subject: Re: [PATCH 1/1] SQUASHME pnfs-submit: replace layoutcommit_ctx with
	rpc_cred
Date: Mon, 24 May 2010 14:37:43 +0800
Message-ID: <AANLkTinvXyrrqR7YpkLOUAJ890oTBdQCgQuNXD9o3gk-@mail.gmail.com>
References: <1274371457-10003-1-git-send-email-andros@netapp.com>
	 <AANLkTinRG_AhVwFZ6a3GllIHSLa3zBDl0zmVDp3btJhn@mail.gmail.com>
	 <AANLkTikCPFKKMWFVCT3AlIz792q12x3QrH3vDVVePPXN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:46799 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756061Ab0EXGhq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 02:37:46 -0400
Received: by vws9 with SMTP id 9so2143120vws.19
        for <linux-nfs@vger.kernel.org>; Sun, 23 May 2010 23:37:44 -0700 (PDT)
In-Reply-To: <AANLkTikCPFKKMWFVCT3AlIz792q12x3QrH3vDVVePPXN-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I see... But what if sync == 1? At that time, data must have already
been freed, so you should not use data->cred anymore.

-- 
tao.
