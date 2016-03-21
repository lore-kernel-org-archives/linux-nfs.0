Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34378 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932436AbcCUTbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 15:31:46 -0400
Received: by mail-lb0-f174.google.com with SMTP id k12so133195079lbb.1
        for <linux-nfs@vger.kernel.org>; Mon, 21 Mar 2016 12:31:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160321153014.GA18948@infradead.org>
References: <56BF34E3.1020003@gmail.com> <20160229095756.GA19397@infradead.org>
 <56D432D5.7000905@gmail.com> <20160229133439.GA4416@infradead.org>
 <56D58CAC.7010603@gmail.com> <CAHQdGtQWxv1vzC_o8x3JSFyW3tMYihF1rcmFGBsGEpddLabejA@mail.gmail.com>
 <20160321153014.GA18948@infradead.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Mon, 21 Mar 2016 19:27:41 +0100
Message-ID: <CAJ75kXbD7Cu91wrfsX7y5dJ-YMbCPuCMATnsDRX_m-V66MMQWg@mail.gmail.com>
Subject: Re: [PATCH] nfs/blocklayout: make sure making a aligned read request
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Peng Tao <tao.peng@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Trond,

If this patch fixes a read hang, is it a good candidate for stable?

Regards,
-- 
William
