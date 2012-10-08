Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33702 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924Ab2JHMUx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 08:20:53 -0400
Date: Mon, 8 Oct 2012 08:20:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.de>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121008122039.GB25231@fieldses.org>
References: <20121002123810.15bd1ee2@notabene.brown>
 <20121002143334.GA1435@fieldses.org>
 <20121003134629.72557522@notabene.brown>
 <20121003151349.GD14313@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909001D77@SACEXCMBX04-PRD.hq.netapp.com>
 <20121003162728.GE14313@fieldses.org>
 <20121004084659.38632320@notabene.brown>
 <20121004160739.GA4693@fieldses.org>
 <20121008170304.37dc6ae9@notabene.brown>
 <5072BC2A.1060100@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5072BC2A.1060100@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 08, 2012 at 07:42:34AM -0400, Steve Dickson wrote:
> Assuming you are using the keyring based idmapper, "nfsidmap -cv" will
> clear the keyring of user and group ids. See nfsidmap(5).

Oh, good, I'd missed that....

> If you using rpc.idmapd, I believe 
>     echo `date +'%s'` > /proc/net/rpc/nfs4.idtoname/flush
> will do the trick.... The CITI faq 
>     http://www.citi.umich.edu/projects/nfsv4/linux/faq/
> has a section on work with this cache...

No, that's just the server-side cache, but if as Neil says the
on-the-wire replies look correct, then the problem is client-side.

--b.
