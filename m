Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:54950 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933339AbdCHAfz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Mar 2017 19:35:55 -0500
Date: Tue, 7 Mar 2017 15:50:58 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-fsdevel@vger.kernel.org, hch@lst.de, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 1/3] fs: Don't copy beyond the end of the file
Message-ID: <20170307235058.GA9879@infradead.org>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-2-kolga@netapp.com>
 <20170302165839.GC5269@birch.djwong.org>
 <9265113A-877D-4C62-9A3F-65D09D0FC404@netapp.com>
 <20170302184057.GM26319@birch.djwong.org>
 <20170307234345.GB29977@infradead.org>
 <0E27E7C0-50AE-4E48-80BF-A9B6738BA4EC@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <0E27E7C0-50AE-4E48-80BF-A9B6738BA4EC@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 07, 2017 at 06:46:55PM -0500, Olga Kornievskaia wrote:
> Anna has added test cases to the xfstest suite. Is there something that’s missing? 

No, we still don't have that.  Anna did one attempt (or maybe two) but
didn't seem to have time to follow up the review comments.  Maybe you
can give it a spin to make sure we at least have basic test coverage,
including the cases mentioned in the man page like this.
