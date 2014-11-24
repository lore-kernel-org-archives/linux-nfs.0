Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35459 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbaKXWRp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2014 17:17:45 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so2538093pdi.31
        for <linux-nfs@vger.kernel.org>; Mon, 24 Nov 2014 14:17:44 -0800 (PST)
Date: Mon, 24 Nov 2014 14:17:42 -0800
From: Omar Sandoval <osandov@osandov.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 0/5] btrfs: implement swap file support
Message-ID: <20141124221742.GA15745@mew.dhcp4.washington.edu>
References: <cover.1416563833.git.osandov@osandov.com>
 <20141121101531.GB21814@mew>
 <20141121101914.GA380@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141121101914.GA380@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 21, 2014 at 02:19:14AM -0800, Christoph Hellwig wrote:
> On Fri, Nov 21, 2014 at 02:15:31AM -0800, Omar Sandoval wrote:
> > Sorry for the noise, looks like Christoph got back to me on the previous RFC
> > just before I sent this out -- disregard this for now.
> 
> If the NFS people are fine with this version I'd certainly welcome it as
> a first step.  Additional improvements are of course always welcome.
>
To follow up with the NFS people, there's some more review going on on the
BTRFS side, but I'd like to have the infrastructure squared away here.
Additional improvements should be mostly on the VFS side.

Thanks!
-- 
Omar
