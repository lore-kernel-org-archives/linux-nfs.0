Return-Path: linux-kernel-owner@vger.kernel.org
Date: Mon, 12 Jan 2015 13:37:18 +0100
From: Christoph Hellwig <hch@lst.de>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Boaz Harrosh <ooo@electrozaur.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs: objlayout: objio_osd: Remove unused function
Message-ID: <20150112123718.GC29325@lst.de>
References: <1421000694-22451-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421000694-22451-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 11, 2015 at 07:24:54PM +0100, Rickard Strandqvist wrote:
> Remove the function objio_alloc_deviceid_node() that is not used anywhere.
> 
> This was partially found by using a static code analysis program called cppcheck.

It needs to be wire up, just like the alloc_deviceid_node instances in
other layout drivers.  I'll send a proper fix.
