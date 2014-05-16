Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57902 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755567AbaEPPMv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 May 2014 11:12:51 -0400
Date: Fri, 16 May 2014 08:12:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] NFSD: Don't clear SUID/SGID after root writing data
Message-ID: <20140516151249.GA27805@infradead.org>
References: <534AA92B.8010805@gmail.com>
 <20140418130220.GF18612@fieldses.org>
 <53512DE5.7050907@gmail.com>
 <5351501B.1010507@gmail.com>
 <20140508161256.GC20976@fieldses.org>
 <536C89D7.6090902@gmail.com>
 <20140509214056.GC497@fieldses.org>
 <20140510051017.GA23444@infradead.org>
 <5375BEBD.50805@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5375BEBD.50805@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 16, 2014 at 03:31:09PM +0800, Kinglong Mee wrote:
> xfstests generic/193 only tests non-root user truncating file
> with root setting SGID/SUID mode. generic/193 will not fail.

generic/193 reproducibly fails for me.

