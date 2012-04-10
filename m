Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35457 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753595Ab2DJUqL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 16:46:11 -0400
Date: Tue, 10 Apr 2012 16:46:08 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
Message-ID: <20120410204608.GI18465@fieldses.org>
References: <20120409161114.GB6482@fieldses.org>
 <1333988226.2688.76.camel@lade.trondhjem.org>
 <20120409162107.GC6482@fieldses.org>
 <1333989216.2688.87.camel@lade.trondhjem.org>
 <4F8314CF.70302@parallels.com>
 <20120409181138.GA9581@fieldses.org>
 <4F8411CC.2070105@parallels.com>
 <20120410133913.GF18465@fieldses.org>
 <4F84537A.40100@parallels.com>
 <20120410142853.7e749ba2@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120410142853.7e749ba2@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 10, 2012 at 02:28:53PM -0400, Jeff Layton wrote:
> This sort of thing is one of the reasons I've been saying that the
> grace period is really a property of the underlying filesystem and not
> of nfsd itself. Of course, we do have to come up with a way to handle
> the grace period that doesn't involve altering every exportable fs.

By the way, the case of multiple containers exporting a single
filesystem does look a lot like an active/active cluster filesystem
export.  It might be an opportunity to prototype the interfaces for
handling that case without having to deal with modifying the DLM.

--b.
