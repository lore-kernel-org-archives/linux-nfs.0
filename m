Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53739 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932500Ab1KHUqC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Nov 2011 15:46:02 -0500
Date: Tue, 8 Nov 2011 23:45:55 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Julia Lawall <julia@diku.dk>, "J. Bruce Fields" <bfields@fieldses.org>,
        kernel-janitors@vger.kernel.org, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/5] net/sunrpc: use kstrtoul, etc
Message-ID: <20111108204555.GA4379@p183.telecom.by>
References: <1320586010-21931-1-git-send-email-julia@diku.dk>
 <1320586010-21931-3-git-send-email-julia@diku.dk>
 <20111108193817.GA3453@p183.telecom.by>
 <alpine.DEB.2.02.1111082113380.1880@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.02.1111082113380.1880@hadrien>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 08, 2011 at 09:19:30PM +0100, Julia Lawall wrote:
> 
> 
> On Tue, 8 Nov 2011, Alexey Dobriyan wrote:
> 
> > On Sun, Nov 06, 2011 at 02:26:47PM +0100, Julia Lawall wrote:
> >> @@
> >> expression a,b;
> >> {int,long} *c;
> >> @@
> >>
> >> -strict_strtoul
> >> +kstrtoul
> >
> > No, no, no!
> 
> Sorry, this was not the real rule I used for the strtoul case.  Instead I 
> used the following:
> 
> @@
> typedef ulong;
> expression a,b;
> {ulong,unsigned long,unsigned int,size_t} *c;
> @@
> 
> -strict_strtoul
> +kstrtoul
>   (a,b,c)
> 
> But now I have seen that there is a separate function for integers, so I 
> have made a rule to use that function when the type is unsigned int.
> 
> > In every case see the type or real data and use appropriate function.
> > kstrtou8() for ports.
> 
> The type of the destination variable in all of these cases is unsigned 
> long.  But maybe that is not enough information to make the 
> transformation in the right way.

That's because previous functions following libc didn't accept anything
less than unsigned long.

For these conversion, one should literally look at every usecase and
see what types data have for real (not unsigned long) and
make conversion and remove explicit EINVAL checks if necesasry.

In sunrpc case: switch to kstrtou8 + remove "> 255" check.

This program doesn't and won't do that.
