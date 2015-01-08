Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:59799 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbbAHRHI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 12:07:08 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so3097276qcx.2
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 09:07:07 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Subject: Re: [PATCH v3 00/49] *** Add Flexfile Layout Module ***
From: Tom Haynes <thomas.haynes@primarydata.com>
In-Reply-To: <20150108144559.GA11530@infradead.org>
Date: Thu, 8 Jan 2015 09:07:06 -0800
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <4144CCD7-8D1B-4871-B27E-BE1061F523A2@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com> <20150108144559.GA11530@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 8, 2015, at 6:45 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> Do you also have a git tree available?  I'd like to test that the
> core pnfs changes don't cause regressions for the block layout driver.


I’ll put one together today.

> 
> Talking about testing, where can I get the flexfiles server to test this
> layout?
> 

The pyNFS prototype that Dros mentioned would be best.