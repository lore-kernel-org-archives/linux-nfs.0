Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59327 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459AbaJGRRE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Oct 2014 13:17:04 -0400
Date: Tue, 7 Oct 2014 10:17:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 02/17] security: make security_file_set_fowner,
 f_setown and __f_setown void return
Message-ID: <20141007171703.GA30274@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-3-git-send-email-jlayton@primarydata.com>
 <CACE9dm-gEfVnHvESfewAPx1vDSdpUW+za=H_zpA8hJd55AR=tA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CACE9dm-gEfVnHvESfewAPx1vDSdpUW+za=H_zpA8hJd55AR=tA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 07, 2014 at 08:11:42PM +0300, Dmitry Kasatkin wrote:
> If file_set_fowner op is now type of "void", how you can actually
> return the value?
> I think compiler must give error. How could you compile it?

Returning void values is a GNU extension.  I've seen it in a few
places in the kernel.  Although in general I'd prefer it we'd remove
it (and have the compiler warn about it).

