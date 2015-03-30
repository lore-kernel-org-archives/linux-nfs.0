Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38779 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbbC3OGp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 10:06:45 -0400
Date: Mon, 30 Mar 2015 07:06:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Marc Eshel <eshel@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH v3 3/3] NFSD: Add support for encoding multiple segments
Message-ID: <20150330140637.GA26244@infradead.org>
References: <OFB111A6D8.016B8BD5-ON88257E0D.001D174D-88257E0D.005268D6@us.ibm.com>
 <20150319153627.GA20852@fieldses.org>
 <OF38D4D18B.19055EC2-ON88257E0D.0059BA03-88257E0D.005A781F@us.ibm.com>
 <20150320151718.GD2036@fieldses.org>
 <20150320162303.GA18786@infradead.org>
 <20150320182621.GH2036@fieldses.org>
 <CAFX2JfkybBPcqD6A8r-jOkPnkL26=NEuK3zhA6TLn-DVam+kfQ@mail.gmail.com>
 <20150324174916.GA28906@infradead.org>
 <55142405.3090000@Netapp.com>
 <CAHQdGtTavsJ5k0taRCBi7CgP1NYjqQmgbQcE-yUkXQOKdQsGpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTavsJ5k0taRCBi7CgP1NYjqQmgbQcE-yUkXQOKdQsGpA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 26, 2015 at 11:32:25AM -0400, Trond Myklebust wrote:
> So there is a clear win in the 100% hole case here, but otherwise the
> statistical fluctuations are dominating the numbers. Can you get us a
> little more stats and then perhaps run the results through nfsometer?

And that's just the uncached reads if I understand the thread correctly.
The cached case isn't uncommon in real life, so regressing it isn't
really an option either.
