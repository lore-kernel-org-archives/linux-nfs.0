Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60265 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab2LQPgy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 10:36:54 -0500
Date: Mon, 17 Dec 2012 10:36:44 -0500
To: Steve French <smfrench@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Pavel Shilovsky <piastry@etersoft.ru>,
        David Laight <david@l8s.co.uk>, Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
Message-ID: <20121217153644.GD23546@fieldses.org>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
 <20121207161602.GA17710@infradead.org>
 <495d17310e0a687d446afc86def0f058@office.etersoft.ru>
 <20121212083401.GW5010@snowdrop.l8s.co.uk>
 <CAKywueSN++ZCNJ1zbET_axuwXd2ZujvSof9H82E3AdeZWY_BgQ@mail.gmail.com>
 <20121214153000.62af6cbc@pyramind.ukuu.org.uk>
 <CAH2r5muRyB2529EcQXFysrSDpMKe0m3JfiEc5929O6oTmG-ThQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAH2r5muRyB2529EcQXFysrSDpMKe0m3JfiEc5929O6oTmG-ThQ@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 14, 2012 at 01:19:18PM -0600, Steve French wrote:
> On Fri, Dec 14, 2012 at 9:30 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> >> We can make this feature (passing O_DENY* flags received from clients
> >> to filesystem) can be turned on/off on Samba/NFS server to let this
> >> particular use case work. In general, I think we really need to be
> >> sure that nobody has a read access for files that a Windows process
> >> opened with O_DENYREAD (because there can be important reasons for the
> >> Windows process to do so).
> >
> > It should only affect windows emulated tasks, nothing else
> 
> yes, but not just wine - there is probably a case for Samba server and
> NFSv4 to optionally request such behafvior).

Agreed, but:

> Also we are likely to
> see more cases where users want to run Samba over an NFS mount and
> vice versa.

I don't personally see the interest in this case.

(And in fact I'd rather we removed the nfs export code for cifs; I seem
to recall from the last discussion that filehandle lookups get ESTALE
for inodes that have gone out of cache, and that that wasn't really
fixable.)

--b.
