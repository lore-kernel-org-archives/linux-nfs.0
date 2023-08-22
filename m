Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43B6CEE49A5
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Aug 2023 02:18:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231893AbjHWCS6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 22 Aug 2023 22:18:58 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33560 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230291AbjHWCS5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Aug 2023 22:18:57 -0400
X-Greylist: delayed 903 seconds by postgrey-1.37 at lindbergh.monkeyblade.net; Tue, 22 Aug 2023 19:18:55 PDT
Received: from symantec4.comsats.net.pk (symantec4.comsats.net.pk [203.124.41.30])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A2BB2185
        for <linux-nfs@vger.kernel.org>; Tue, 22 Aug 2023 19:18:55 -0700 (PDT)
X-AuditID: cb7c291e-06dff70000002aeb-4b-64e5541f9508
Received: from iesco.comsatshosting.com (iesco.comsatshosting.com [210.56.28.11])
        (using TLS with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        by symantec4.comsats.net.pk (Symantec Messaging Gateway) with SMTP id 8E.A2.10987.F1455E46; Wed, 23 Aug 2023 05:34:39 +0500 (PKT)
DomainKey-Signature: a=rsa-sha1; c=nofws; q=dns;
        d=iesco.com.pk; s=default;
        h=received:content-type:mime-version:content-transfer-encoding
          :content-description:subject:to:from:date:reply-to;
        b=I7MENDwiux62MU2sB0vhNYY8faVCwV3vVTRUb/t6LGj/fPRFkVcm2y3g2LBBJqmnd
          rJ16dUKFARJLL4HXCEgWdc1cFePiW9gS0L3xpKZGDzHiHrK0Cj2obBBjbZZz4OZ41
          7v2n/lRmV8e+9UojjzngHhCSS9mMR/YhqUwzkIa2w=
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=iesco.com.pk; s=default;
        h=reply-to:date:from:to:subject:content-description
          :content-transfer-encoding:mime-version:content-type;
        bh=GMzYzcyTxDsE6wX/XHG6MHqAdAiHrhqbmmLQ/TZ1QnQ=;
        b=MYuobhzEmHdCgm91gVAiifBq7Bt2VlfxRz982EtkUAj8Xct1EsT8b0piuQaug/CHp
          mJhrwm1V6xaGYRrJvjUU4XceVdZKrfh4SZ7BHhQ0mhKSeY3CGhTLKzPFeBJ8/e+0f
          EzMCsiMJbaug/sqrws9D7AzGM7xihlAyWwxaLOi3o=
Received: from [94.156.6.90] (UnknownHost [94.156.6.90]) by iesco.comsatshosting.com with SMTP;
   Wed, 23 Aug 2023 04:31:04 +0500
Message-ID: <8E.A2.10987.F1455E46@symantec4.comsats.net.pk>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Description: Mail message body
Subject: Re; Interest,
To:     linux-nfs@vger.kernel.org
From:   "Chen Yun" <pso.chairmanbod@iesco.com.pk>
Date:   Tue, 22 Aug 2023 16:31:18 -0700
Reply-To: chnyne@gmail.com
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFlrLLMWRmVeSWpSXmKPExsVyyUKGW1c+5GmKwYTTUhYXDpxmdWD0+LxJ
        LoAxissmJTUnsyy1SN8ugStjyboLLAW7mSva+hexNDA+Zupi5OSQEDCR2PNxEmMXIxeHkMAe
        Jom/Pw+ygDgsAquZJQ53TmKFcB4ySxzfdo8VoqyZUeLlynnMIP28AtYSJx72s4HYzAJ6Ejem
        TmGDiAtKnJz5hAUiri2xbOFroHoOIFtN4mtXCUhYWEBM4tO0ZewgtoiArMTlf6/AytkE9CVW
        fG1mBLFZBFQllp3/AxYXEpCS2HhlPdsERv5ZSLbNQrJtFpJtsxC2LWBkWcUoUVyZmwgMtmQT
        veT83OLEkmK9vNQSvYLsTYzAQDxdoym3g3HppcRDjAIcjEo8vD/XPUkRYk0sA+o6xCjBwawk
        wiv9/WGKEG9KYmVValF+fFFpTmrxIUZpDhYlcV5boWfJQgLpiSWp2ampBalFMFkmDk6pBkan
        cwpn7jz+n77k9xfWOg/Zoy4ng3/UaVpe/3v6wd5pZjnfDt+dprzj+JpZsRdX29y7Yr7snYva
        9MWOOW8W2djOFrT/LONY/Kt6Zw7rxO9TvEs2/9tzW7p7RZFddnfkr+Mzlt2KjL2tpylc9nJy
        omPePwHn32FGx1eol8xg/jr578PUKKfufy/DlViKMxINtZiLihMBYyDQA0ACAAA=
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Re; Interest,

I am interested in discussing the Investment proposal as I explained
in my previous mail. May you let me know your interest and the
possibility of a cooperation aimed for mutual interest.

Looking forward to your mail for further discussion.

Regards

------
Chen Yun - Chairman of CREC
China Railway Engineering Corporation - CRECG
China Railway Plaza, No.69 Fuxing Road, Haidian District, Beijing, P.R.
China

