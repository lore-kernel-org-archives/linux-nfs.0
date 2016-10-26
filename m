Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38841 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752344AbcJZI0l (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Oct 2016 04:26:41 -0400
Date: Wed, 26 Oct 2016 01:26:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v2 0/4] Add copy_file_range() tests
Message-ID: <20161026082638.GA19419@infradead.org>
References: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 07, 2016 at 03:56:15PM -0400, Anna Schumaker wrote:
> These tests exercise the copy_file_range() system call, and check copying
> data to both a new file and overwriting data inside an existing file.  I use
> the xfs_io "copy_range" command for the actual copies, so running these
> tests requires an up-to-date version of xfsprogs.

Hi Anna,

what's the status of these tests?  Did you get a chance to look
into xfs_io copyfile support?
