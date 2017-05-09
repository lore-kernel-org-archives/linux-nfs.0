Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:52992 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752993AbdEIT4a (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 15:56:30 -0400
Date: Tue, 9 May 2017 12:56:28 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4.1: Work around a Linux server bug...
Message-ID: <20170509195628.GA22486@infradead.org>
References: <20170509195335.114163-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170509195335.114163-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 09, 2017 at 03:53:35PM -0400, Trond Myklebust wrote:
> It turns out the Linux server has a bug in its implementation of
> supattr_exclcreat; it returns the set of all attributes, whether
> or not they are supported by minor version 1.

Are you going to send a fix?
