Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:33648 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750984AbeCGGr6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2018 01:47:58 -0500
Date: Tue, 6 Mar 2018 22:47:56 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: Kernel ops with flexfiles
Message-ID: <20180307064756.GA15922@infradead.org>
References: <1569515727.10818617.1520288819283.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1569515727.10818617.1520288819283.JavaMail.zimbra@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI, I see very similar issues with blocklayout, also caused by the
refcount changes.  But I didn't really didn't have any time to dig
into it yet.
