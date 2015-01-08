Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:59970 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757170AbbAHTgd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 14:36:33 -0500
Received: by mail-qc0-f174.google.com with SMTP id c9so4138701qcz.5
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 11:36:33 -0800 (PST)
Date: Thu, 8 Jan 2015 11:36:27 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 00/49] *** Add Flexfile Layout Module ***
Message-ID: <20150108193627.GA64352@jhereg.localdomain>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
 <20150108144559.GA11530@infradead.org>
 <4144CCD7-8D1B-4871-B27E-BE1061F523A2@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4144CCD7-8D1B-4871-B27E-BE1061F523A2@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2015 at 09:07:06AM -0800, Tom Haynes wrote:
> 
> > On Jan 8, 2015, at 6:45 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > Do you also have a git tree available?  I'd like to test that the
> > core pnfs changes don't cause regressions for the block layout driver.
> 
> 
> I’ll put one together today.
> 

The [flexfiles] branch of 

git://git.linux-nfs.org/projects/loghyr/linux-nfs.git

should suffice.
