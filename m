From: Neil Brown <neilb@suse.de>
Subject: Re: mount.nfs: protocol fallback when server doesn't support TCP
Date: Tue, 7 Sep 2010 10:02:07 +1000
Message-ID: <20100907100207.5119d61c@notabene>
References: <20100826120635.4c3157bc@notabene>
	<659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com>
	<20100830103025.70d09ec8@notabene>
	<BC2D2164-0836-4DAC-99C5-C7BE23D3B163@oracle.com>
	<20100831110024.68e8877d@notabene>
	<4B6431AA-0FFD-4FE9-9DF4-4AF7D2B2AD20@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:59899 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754165Ab0IGACP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Sep 2010 20:02:15 -0400
In-Reply-To: <4B6431AA-0FFD-4FE9-9DF4-4AF7D2B2AD20@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 31 Aug 2010 16:29:59 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Aug 30, 2010, at 9:00 PM, Neil Brown wrote:
> 
> > Two observations I've made while exploring which are only tangential to the
> > current issue:
> > 
> > 1/ if I give an invalid proto name
> >          mount -o proto=fred .....
> >    the mount command fails (as it should) but gives no error message.
> 
> I was not able to reproduce this.  I get an appropriate error message from mount.nfs when built either with TI-RPC or without.  I'm using the latest upstream nfs-utils + my mountd patches.
> 

Ahh yes, fixed by

commit 9ac7a15017b876d4d8d3a4502ebaf954f36f7f54
Author: Steve Dickson <steved@redhat.com>
Date:   Thu Jun 3 08:53:22 2010 -0400

    mount.nfs: silently fails when the network protocol is not found
    
    mount.nfs should display some type of error diagnostics when
    the network protocol can not be determined.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>


Thanks,
NeilBrown
