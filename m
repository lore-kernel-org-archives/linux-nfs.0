Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19240 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798Ab3FYOOu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 10:14:50 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Nadav Shemer <nadav@tonian.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Lev <solo@tonian.com>, Idan Kedar <idank@tonian.com>,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: LAYOUTGET and NFS4ERR_DELAY: a few questions
Date: Tue, 25 Jun 2013 14:14:46 +0000
Message-ID: <1372169680.5968.17.camel@leira.trondhjem.org>
References: <CADnca3voFCr1xbwNcHEq-YCip2ghBrH3Ni2XARfcW6pdLw1K-A@mail.gmail.com>
	 <20130624193153.GC23596@fieldses.org>
	 <CADnca3vEfZZvWT_EfgBJ0AcmuUGXfVtGvasQqQQSAoQF7OLPJw@mail.gmail.com>
	 <20130625134325.GA17511@fieldses.org>
	 <CADnca3ugP74U7N5wBLHyu-X2Bi-Nz4B_8zLFOexRyhN7yNtYow@mail.gmail.com>
In-Reply-To: <CADnca3ugP74U7N5wBLHyu-X2Bi-Nz4B_8zLFOexRyhN7yNtYow@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-06-25 at 17:00 +0300, Nadav Shemer wrote:
> On Tue, Jun 25, 2013 at 4:43 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Tue, Jun 25, 2013 at 02:51:48PM +0300, Nadav Shemer wrote:
> >> This makes me ponder. If the server blocks while waiting for
> >> conflicting layouts to be recalled, I think we can theoretically reach
> >> a deadlock (if we take up all the nfsd threads or all the clients'
> >> session slots): client A hold layout to file X, and requests layout to
> >> file Y, while client B holds layout to file Y and requests layout to
> >> file X.
> >> To avoid this, we pretty much have to return DELAY for LAYOUTGET
> >
> > I agree that you wouldn't want to block waiting for a client to return a
> > layout.  Is this a case for NFS4ERR_LAYOUTTRYLATER?
> Yes, I believe it is.
> Specifically the Linux client treats them all the same (LAYOUTTRYLATER
> and RECALLCONFLICT are both mapped to DELAY before passing to
> nfs4_async_handle_error)
> Do you think there is a case for an exponential backoff in this case
> for a specific (non-DELAY) error code?

Why do we care? If this is about passing some unit test somewhere, then
I frankly don't give a damn.

If. OTOH, there is a valid use case where 2 clients must request
conflicting layouts for the same file, then let's discuss that specific
case.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
