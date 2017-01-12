Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:43610 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750755AbdALLpy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 06:45:54 -0500
Subject: Re: [PATCH 9/9] treewide: Inline ib_dma_map_*() functions
To: Bart Van Assche <bart.vanassche@sandisk.com>,
        Doug Ledford <dledford@redhat.com>
References: <20170111005648.14988-1-bart.vanassche@sandisk.com>
 <20170111005648.14988-10-bart.vanassche@sandisk.com>
Cc: Latchesar Ionkov <lucho@ionkov.net>, devel@driverdev.osuosl.org,
        linux-nfs@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Oleg Drokin <oleg.drokin@intel.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, target-devel@vger.kernel.org,
        Ron Minnich <rminnich@sandia.gov>,
        James Simmons <jsimmons@infradead.org>,
        v9fs-developer@lists.sourceforge.net, rds-devel@oss.oracle.com,
        "David S . Miller" <davem@davemloft.net>,
        lustre-devel@lists.lustre.org
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <811bac91-39f4-edac-db8a-d44989440b21@grimberg.me>
Date: Thu, 12 Jan 2017 13:45:31 +0200
MIME-Version: 1.0
In-Reply-To: <20170111005648.14988-10-bart.vanassche@sandisk.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
