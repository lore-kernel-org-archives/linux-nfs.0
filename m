Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72E63C4332F
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Dec 2022 05:30:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229546AbiLHFaZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Dec 2022 00:30:25 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:35440 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229530AbiLHFaY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2022 00:30:24 -0500
X-Greylist: delayed 546 seconds by postgrey-1.37 at lindbergh.monkeyblade.net; Wed, 07 Dec 2022 21:30:24 PST
Received: from mail.valinux.co.jp (mail.valinux.co.jp [210.128.90.3])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1672E5E3CA
        for <linux-nfs@vger.kernel.org>; Wed,  7 Dec 2022 21:30:24 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
        by mail.valinux.co.jp (Postfix) with ESMTP id 8AD0BA8F4D;
        Thu,  8 Dec 2022 14:21:16 +0900 (JST)
X-Virus-Scanned: Debian amavisd-new at valinux.co.jp
Received: from mail.valinux.co.jp ([127.0.0.1])
        by localhost (mail.valinux.co.jp [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id 9EYdxVkNpBll; Thu,  8 Dec 2022 14:21:16 +0900 (JST)
Received: from brer (vagw.valinux.co.jp [210.128.90.14])
        by mail.valinux.co.jp (Postfix) with ESMTP id 5A5E3A8F48;
        Thu,  8 Dec 2022 14:21:16 +0900 (JST)
From:   =?iso-2022-jp?B?TUlOT1VSQSBNYWtvdG8gLyAbJEJMJzE6GyhCIBskQj8/GyhC?= 
        <minoura@valinux.co.jp>
To:     =?iso-2022-jp?B?U0hJTUFNT1RPIEhJUk9TSEkoGyRCRWdLXCEhTTU7VhsoQik=?= 
        <h-shimamoto@nec.com>
Cc:     "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: serialize gss upcalls for the same uid
References: <20221207052341.3163040-1-h-shimamoto@nec.com>
        <TYAPR01MB491287D674889E7FB43D044FFF1D9@TYAPR01MB4912.jpnprd01.prod.outlook.com>
Date:   Thu, 08 Dec 2022 14:21:16 +0900
In-Reply-To: <TYAPR01MB491287D674889E7FB43D044FFF1D9@TYAPR01MB4912.jpnprd01.prod.outlook.com>
        ("SHIMAMOTO \=\?iso-2022-jp\?B\?SElST1NISSgbJEJFZ0tcISFNNTtWGyhCKSIncw\=\=\?\=
 message of "Thu, 8 Dec 2022
        03:13:44 +0000")
Message-ID: <kk5r0xaii7n.fsf@brer.local.valinux.co.jp>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.3 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> Should we use gss_release_msg(old) ?
> It might be the last decrement of the count and lead to resource leak.

Right, we must use gss_release_msg() here.  Thanks for pointing out.

-- 
Minoura Makoto <minoura@valinux.co.jp>
VA Linux Systems Japan
