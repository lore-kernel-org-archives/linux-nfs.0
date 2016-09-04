Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail03-md.ns.itscom.net ([175.177.155.113]:44469 "EHLO
        mail03-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752138AbcIDS6Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Sep 2016 14:58:24 -0400
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: 4.8-rcN nfs O_DYSNC, write(2) doesn't return ENOSPC
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1472919194.11308.1.camel@primarydata.com>
References: <3647.1472877116@jrobl> <1472919194.11308.1.camel@primarydata.com>
Date: Mon, 05 Sep 2016 03:58:19 +0900
Message-ID: <8571.1473015499@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond Myklebust:
> Thanks for testing! Does the following patch fix the issue for you?

Thank you for quick response and the patch.
It worked!


J. R. Okajima
