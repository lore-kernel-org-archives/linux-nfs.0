Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59512 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196AbaBDQUx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 11:20:53 -0500
Date: Tue, 4 Feb 2014 11:20:52 -0500
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        simo@redhat.com
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140204162052.GA5295@fieldses.org>
References: <20140130172451.7a354ce4@notabene.brown>
 <52F003A1.3060908@RedHat.com>
 <20140204093452.7b6d7c7d@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140204093452.7b6d7c7d@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 04, 2014 at 09:34:52AM +1100, NeilBrown wrote:
> On Mon, 03 Feb 2014 16:01:21 -0500 Steve Dickson <SteveD@redhat.com> wrote:
> > Also how does gss-proxy come to play in all this? Maybe we 
> > just use  gss-proxy by default and retire rpc.svcgssd.
> 
> I haven't really be following and so am only dimly aware of gss-proxy.
> It's a replacement for rpc.svcgssd - right?
> So we should get it to start in the same circumstances as rpc.svcgssd?
> 
> Is there some easy test - eg something existing in the filesystem - that we
> could use to see if the kernel supports gss-proxy ?

There's a /proc/net/rpc/use-gss-proxy file.

(But doesn't gss-proxy have users other than nfsd?)

> Also, I've been wondering if we could avoid the need to explicitly enable
> the gss stuff by gating it on the existence of /etc/krb5.keytab.
> Do you think that would be reasonable?

That would be great.  I hate that people have to care about these
support daemons, they should just be started automatically when they're
needed.

Is /etc/krb5.keytab the best indicator?

Simplest might be to start unconditionally and just not care if it
fails.  Or is there a problem cluttering up logs with unimportant
failures?

--b.
