Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f41.google.com ([209.85.160.41]:51726 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857AbaA0Ozb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jan 2014 09:55:31 -0500
Received: by mail-pb0-f41.google.com with SMTP id up15so5967459pbc.14
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jan 2014 06:55:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140127143420.GA17165@fieldses.org>
References: <20140124063202.GA23937@ulegcprs1.emea.nsn-net.net>
	<20140124192830.GA16164@fieldses.org>
	<CAObFj3z9o7QzSk0AOfUZWk1+xv4k6mB9OHtuMC5JjUqvudXL2w@mail.gmail.com>
	<20140127143420.GA17165@fieldses.org>
Date: Mon, 27 Jan 2014 15:55:29 +0100
Message-ID: <CAObFj3w4yuUkbinM1N=u3bMqgqwdkPg=7BROD5uN2pQLkz-h9A@mail.gmail.com>
Subject: Re: [PATCH] use NFS4_MAXMINOR instead of hard coded number
From: Robert Schiele <rschiele@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 27, 2014 at 3:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> That's a bug that was fixed by 93648ecc10bae7ed542056abb55f4b8f10ddbbb9
> "nfsd: fix minorversion-choosing interface"

Ah, cool. Missed that one.

Thanks,
Robert
