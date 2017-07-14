Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50380 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbdGNHJ1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 03:09:27 -0400
Date: Fri, 14 Jul 2017 00:09:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
Message-ID: <20170714070922.GA10669@infradead.org>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <CA+55aFz=JhykX-zU0f2FwrPbGndR8skQkuODU_YjQKTVs6OioQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFz=JhykX-zU0f2FwrPbGndR8skQkuODU_YjQKTVs6OioQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 13, 2017 at 02:43:14PM -0700, Linus Torvalds wrote:
> On Thu, Jul 13, 2017 at 2:16 PM, Anna Schumaker
> <schumaker.anna@gmail.com> wrote:
> >
> >   git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-1
> 
> Btw, your key seems to have expired, and doing a refresh on it doesn't fix it.
> 
> I'm sure you've refreshed your key, but apparently that refresh hasn't
> been percolated to the public keyservers?

As someone who has run into an issue in that area recently:  I manually
had to refresh and re-upload my signing subkey and not just the primary
key, which wa rather confusing and took a long time to sort out.
