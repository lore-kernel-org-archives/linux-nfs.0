Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:48904 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423489Ab2KNW0a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 17:26:30 -0500
Received: by mail-wg0-f44.google.com with SMTP id dr13so465334wgb.1
        for <linux-nfs@vger.kernel.org>; Wed, 14 Nov 2012 14:26:28 -0800 (PST)
Date: Wed, 14 Nov 2012 23:26:06 +0100 (CET)
From: Eldad Zack <eldad@fogrefinery.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Sven Geggus <lists@fuchsschwanzdomain.de>, linux-nfs@vger.kernel.org
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
In-Reply-To: <20121114160712.GG23604@fieldses.org>
Message-ID: <alpine.LNX.2.00.1211142325510.1216@xoschi>
References: <20121109200730.GI6171@fieldses.org> <E1TWxKX-00025I-J2@diesel.geggus.net> <20121109232410.GK6171@fieldses.org> <20121112091717.GA1610@geggus.net> <20121113224005.GA11545@fieldses.org> <20121114005815.GA23604@fieldses.org>
 <20121114160712.GG23604@fieldses.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 14 Nov 2012, J. Bruce Fields wrote:
> On Tue, Nov 13, 2012 at 07:58:15PM -0500, J. Bruce Fields wrote:
> > On Tue, Nov 13, 2012 at 05:40:05PM -0500, J. Bruce Fields wrote:
> > > On Mon, Nov 12, 2012 at 10:17:17AM +0100, Sven Geggus wrote:
> > > > J. Bruce Fields schrieb am Samstag, den 10. November um 00:24 Uhr:
> > > > 
> > > > 4294967295 is UINT_MAX and this place is where it behaves differently on a good
> > > > kernel where the write call will succeed:
> > > > 
> > > > write(4, "4294967295 1352710828 0 \n", 25) = 25
> > > > 
> > > > Sven
> > > > 
> > > > P.S.: Your patched svcauth_gss.c will give me an "access denied by server"
> > > > while mounting instead of the infinite delay:
> > > >  ~/ # mount -t nfs4 -o sec=krb5 testsrv:/storage /mnt/
> > > > mount.nfs4: access denied by server while mounting testsrv:/storage
> > > 
> > > So, looks like the same get_int problem exists in several other places.
> > > Could you try the following instead of the previous patch?  I think I
> > > got them all this time....
> > 
> > Oh, cripes, but this isn't good enough--svcgssd actually passes down -1
> > id's.  Ugh--I'll take a closer look tomorrow.
> 
> Yeah, for backwards compatibility reasons we probably don't want to
> reject either -1 or 4294967295.
> 
> So I'm inclined to revert unless Eldad has a better idea.

I support that - please revert. I don't know my way around the code 
enough to suggest a good solution at this point.

Cheers,
Eldad

