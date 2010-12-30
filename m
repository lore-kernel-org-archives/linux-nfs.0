Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:34940 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177Ab0L3Ivk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Dec 2010 03:51:40 -0500
Date: Thu, 30 Dec 2010 10:51:39 +0200
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Rob Landley <rob@landley.net>
Cc: "Kirill A. Shutemov" <kas@openvz.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Message-ID: <20101230085139.GA29697@shutemov.name>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 29, 2010 at 08:13:50PM -0600, Rob Landley wrote:
> On Wed, Dec 29, 2010 at 7:14 AM, Kirill A. Shutemov <kas@openvz.org> wrote:
> >
> > Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> > Only for client for now.
> 
> What would a test case for this look like?  (Is there some way to tell
> an nfs mount to use a specific instance of rpc_pipefs or something?)

You can create a new instance of rpc_pipefs using 'newinstance'
mountoption.

Then you can specify which rpc_pipefs to use with 'rpcmount' mountoption
of nfs mount. If none specifed, '/var/lib/nfs/rpc_pipefs' uses by default.
If no rpcmount mountoption, no rpc_pipefs was found at
'/var/lib/nfs/rpc_pipefs' and we are in init's mount namespace, we use
init_rpc_pipefs.

-- 
 Kirill A. Shutemov
