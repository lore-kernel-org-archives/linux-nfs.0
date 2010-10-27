Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35651 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752046Ab0J0Sw7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 14:52:59 -0400
In-Reply-To: <AANLkTimZSj7Y8KUic-VLSgrPFTf5wc_KRdfedzLAkNKT@mail.gmail.com>
References: <20101026164549.GD19445@fieldses.org> <AANLkTinTXoGiFap-vfu0P_SXb5xS+gMsHOwQtN3Hra3r@mail.gmail.com>
 <20101027174016.GA18974@fieldses.org> <201010272020.33049.arnd@arndb.de> <AANLkTimZSj7Y8KUic-VLSgrPFTf5wc_KRdfedzLAkNKT@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Oct 2010 11:43:59 -0700
Message-ID: <AANLkTin53pdmfaBahExgi79XjaeFtP5wCS=rrKxfrAHs@mail.gmail.com>
Subject: Re: nfsd changes for 2.6.37
To: Arnd Bergmann <arnd@arndb.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 27, 2010 at 11:42 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Feel free to edit the message/patch to your hearts content.

Oh, and if you want me to just commit this part, I can do so. It
doesn't make much sense without the other parts to actually make it
useful, though, so it probably makes more sense to come with them.

                    Linus
