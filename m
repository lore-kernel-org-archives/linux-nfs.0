Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45227 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757670Ab2JQTCm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Oct 2012 15:02:42 -0400
Date: Wed, 17 Oct 2012 15:02:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Trond.Myklebust@netapp.com, davem@davemloft.net, davej@redhat.com,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Prevent kernel stack corruption on long values
 of flush
Message-ID: <20121017190233.GA8630@fieldses.org>
References: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com>
 <20120718173913.GA1298@fieldses.org>
 <CA+1xoqcgWTP8pAY3Ok2R0JM-ZXSkGroEvAFcqP0KaK=dABiTXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+1xoqcgWTP8pAY3Ok2R0JM-ZXSkGroEvAFcqP0KaK=dABiTXA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 17, 2012 at 01:59:39PM -0400, Sasha Levin wrote:
> On Wed, Jul 18, 2012 at 1:39 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Tue, Jul 17, 2012 at 12:01:26AM +0200, Sasha Levin wrote:
> >> The buffer size in read_flush() is too small for the longest possible values
> >> for it. This can lead to a kernel stack corruption:
> >
> > Thanks!
> 
> I've just stumbled on this crash again, and noticed that this patch
> never made it in.
> 
> Was it just a mixup, or is something still missing?

Oh, man, I guess I got distracted by the subsequent base10len()
discussion.

Added to my for-3.7 branch, I'll push that out after some tests and
hopefully send in a pull request tomorrow.

Thanks for noticing the ommission.

--b.
