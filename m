From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: numeric UIDs
Date: Fri, 13 Aug 2010 13:37:16 -0400
Message-ID: <20100813173716.GA21834@fieldses.org>
References: <1280873719.14520.17.camel@heimdal.trondhjem.org>
 <20100803222337.GA9752@fieldses.org>
 <1280874675.14520.23.camel@heimdal.trondhjem.org>
 <20100803224245.GB9752@fieldses.org>
 <1280887336.24669.23.camel@heimdal.trondhjem.org>
 <20100805153421.GD27141@fieldses.org>
 <20100812092232.344314b2@notabene>
 <4C6559FA.5070809@RedHat.com>
 <20100813163156.GA16863@fieldses.org>
 <4C658146.90207@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Jim Rees <rees@umich.edu>, Daniel.Muntz@emc.com,
	linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48635 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761879Ab0HMRjP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 13:39:15 -0400
In-Reply-To: <4C658146.90207-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 13, 2010 at 01:30:46PM -0400, Steve Dickson wrote:
> 
> 
> On 08/13/2010 12:31 PM, J. Bruce Fields wrote:
> > There are four cases where translation can be done:
> > 
> > 	Sending id from server to client (ls, stat, getacl):
> > 		1. server uid -> string
> > 		2. string -> client uid
> > 	Sending id from client to server (chown, setacl):
> > 		3. client uid -> string
> > 		4. string -> client uid
> > 
> > Cases 1 and 2 are uncontroversial.  Definitely map ascii-fied integers
> > in both of those cases.
> Does "ascii-fied integers" mean "3606" (a mapping without the @domain part)?

That's what I meant, yes.

> 
> > 
> > Case 4 violates the SHOULD on page 47.  Which would make case 3 useless
> > if all servers respect that SHOULD.  I think we should ignore the SHOULD
> > and implement 3 and 4 too, but Trond may not agree.
> > 
> > I suppose we could make this all configurable, and then argue about what
> > the defaults should be.  If we implement all this in idmapd then that's
> > easy.
> I guess... I would think whatever make the v2/v3 to v4 transition
> seamless would be the best default... 
>  
> > 
> > I don't know what other clients and servers do.  Probably 1 and 2 at
> > least, but maybe it's something to check at the next bakeathon.
> > 
> > Do we actually use an @-less "nobody" as suggested in the last
> > paragraph?  If not that might be something else to fix.
> It appears we do... see idtonameres()....

OK, good.

--b.
