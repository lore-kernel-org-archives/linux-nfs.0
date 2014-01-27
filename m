Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43860 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753712AbaA0O5W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jan 2014 09:57:22 -0500
Date: Mon, 27 Jan 2014 09:57:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Robert Schiele <rschiele@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] use NFS4_MAXMINOR instead of hard coded number
Message-ID: <20140127145722.GB17165@fieldses.org>
References: <20140124063202.GA23937@ulegcprs1.emea.nsn-net.net>
 <20140124192830.GA16164@fieldses.org>
 <CAObFj3z9o7QzSk0AOfUZWk1+xv4k6mB9OHtuMC5JjUqvudXL2w@mail.gmail.com>
 <20140127143420.GA17165@fieldses.org>
 <CAObFj3w4yuUkbinM1N=u3bMqgqwdkPg=7BROD5uN2pQLkz-h9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAObFj3w4yuUkbinM1N=u3bMqgqwdkPg=7BROD5uN2pQLkz-h9A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 27, 2014 at 03:55:29PM +0100, Robert Schiele wrote:
> On Mon, Jan 27, 2014 at 3:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > That's a bug that was fixed by 93648ecc10bae7ed542056abb55f4b8f10ddbbb9
> > "nfsd: fix minorversion-choosing interface"
> 
> Ah, cool. Missed that one.

OK, good, then could you respin your patch to make the maximum the
maximum number of bits storable in the data type?  Or would you like me
to?

--b.
