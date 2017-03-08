Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:57829 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751639AbdCHQOl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Mar 2017 11:14:41 -0500
Date: Wed, 8 Mar 2017 07:57:16 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 1/3] fs: Don't copy beyond the end of the file
Message-ID: <20170308155716.GA16774@infradead.org>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-2-kolga@netapp.com>
 <20170302165839.GC5269@birch.djwong.org>
 <9265113A-877D-4C62-9A3F-65D09D0FC404@netapp.com>
 <20170302184057.GM26319@birch.djwong.org>
 <20170307234345.GB29977@infradead.org>
 <0E27E7C0-50AE-4E48-80BF-A9B6738BA4EC@netapp.com>
 <20170307235058.GA9879@infradead.org>
 <1523DC5D-A162-4EB7-AAD7-F0C1BF8B57A8@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1523DC5D-A162-4EB7-AAD7-F0C1BF8B57A8@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 08, 2017 at 10:39:11AM -0500, Olga Kornievskaia wrote:
> 
> I’m reading some mail archives and I see that Anna submitted patches for xfstests. The comment was to re-work it as a part of xfs_io command. She posted the patches for that. According to the announcement I see here: http://oss.sgi.com/archives/xfs/2016-08/msg00221.html it says it’s including the new copy_file_range command in xfs_io. I don’t run these tests so I don’t know but it look to me that the tests are in.

That's xfsprogs and the xfs_io command.  Now that this step is done
someone (e.g. Anna or you) needs to send the patches to xfstests that
use this command.
