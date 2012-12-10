Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46611 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826Ab2LJQlY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2012 11:41:24 -0500
Date: Mon, 10 Dec 2012 11:41:16 -0500
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: Christoph Hellwig <hch@infradead.org>, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        wine-devel@winehq.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
Message-ID: <20121210164116.GC13327@fieldses.org>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
 <20121207161602.GA17710@infradead.org>
 <495d17310e0a687d446afc86def0f058@office.etersoft.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <495d17310e0a687d446afc86def0f058@office.etersoft.ru>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 08, 2012 at 12:43:14AM +0400, Pavel Shilovsky wrote:
> The problem is the possibility of denial-of-service attacks here. We
> can try to prevent them by:
> 1) specifying an extra security bit on the file that indicates that
> share flags are accepted (like we have for mandatory locks now) and
> setting it for neccessary files only, or
> 2) adding a special mount option (but it it probably makes sense if
> we decided to add this support for CIFS and NFS only).

In the case of knfsd and samba exporting a common filesystem, you'd also
want to be able to enforce it on the exported filesystem.

--b.
