Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60092 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab0IAVG0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Sep 2010 17:06:26 -0400
Date: Wed, 1 Sep 2010 17:05:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: Tim Gardner <tim.gardner@canonical.com>, linux-nfs@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Trond.Myklebust@netapp.com
Subject: Re: nfsd deadlock, 2.6.36-rc3
Message-ID: <20100901210555.GB10507@fieldses.org>
References: <4C7E73CB.7030603@canonical.com>
 <20100901165400.GB1201@fieldses.org>
 <20100902065551.079e297c@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100902065551.079e297c@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 02, 2010 at 06:55:51AM +1000, Neil Brown wrote:
> On Wed, 1 Sep 2010 12:54:01 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > For that reason we just don't support loopback mounts--they're OK for
> > light testing, but it would be difficult to make them completely robust
> > under load.
> 
> I wonder if we could use 'containers' to partition available memory between
> 'nfsd threads' and 'everything else'??  Probably not worth the effort.

cgroups, I don't know, I guess the essential thing would be to make sure
that nfsd has the resources it needs to make forward progress, however
slowly--even if it means, for example, only enough to keep a single
thread processing requests.

--b.
