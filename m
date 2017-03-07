Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:36366 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756558AbdCHABx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Mar 2017 19:01:53 -0500
Date: Tue, 7 Mar 2017 15:43:45 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Olga Kornievskaia <kolga@netapp.com>, linux-fsdevel@vger.kernel.org,
        hch@lst.de, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 1/3] fs: Don't copy beyond the end of the file
Message-ID: <20170307234345.GB29977@infradead.org>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-2-kolga@netapp.com>
 <20170302165839.GC5269@birch.djwong.org>
 <9265113A-877D-4C62-9A3F-65D09D0FC404@netapp.com>
 <20170302184057.GM26319@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170302184057.GM26319@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 02, 2017 at 10:40:57AM -0800, Darrick J. Wong wrote:
> Never mind, I misread vfs_copy as vfs_clone and thought you were talking
> about something else. :(
> 
> Sorry about the noise.

And either way we'll need test coverage for copy_file_range before we
do any more changes to it.  I'm sick and tired of this doctoring around
without having any test coverage.  I've asked for it again and again
and we've made very little progress despite having the code in the tree
for almost a year and a half.
