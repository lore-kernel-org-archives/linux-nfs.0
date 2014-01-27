Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50488 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138AbaA0OeV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jan 2014 09:34:21 -0500
Date: Mon, 27 Jan 2014 09:34:20 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Robert Schiele <rschiele@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] use NFS4_MAXMINOR instead of hard coded number
Message-ID: <20140127143420.GA17165@fieldses.org>
References: <20140124063202.GA23937@ulegcprs1.emea.nsn-net.net>
 <20140124192830.GA16164@fieldses.org>
 <CAObFj3z9o7QzSk0AOfUZWk1+xv4k6mB9OHtuMC5JjUqvudXL2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAObFj3z9o7QzSk0AOfUZWk1+xv4k6mB9OHtuMC5JjUqvudXL2w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 25, 2014 at 05:23:28AM +0100, Robert Schiele wrote:
> On Fri, Jan 24, 2014 at 8:28 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > While we're at it, is there any harm to letting NFS4_MAXMINOR be much
> > higher?  That would save the need to rebuild nfs-utils just because you
> > want to test a kernel with new minor version support.
> 
> That does not work. This constant is used to generate the string to be
> thrown into the kernel and the kernel complains about items in the
> string it does not know about, even if they are disabled, like "-4.7".
> It would work if at the same time you got a patch into the kernel that
> it no longer complains about unknown items that are disabled.

That's a bug that was fixed by 93648ecc10bae7ed542056abb55f4b8f10ddbbb9
"nfsd: fix minorversion-choosing interface"

--b.
