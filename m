From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Fw: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 12:48:11 -0400
Message-ID: <20110729164811.GK23194@fieldses.org>
References: <20110729153207.17af3085@notabene.brown>
 <4E324DB4.7060600@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Greg Banks <gnb@fastmail.fm>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48978 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136Ab1G2QsP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 12:48:15 -0400
In-Reply-To: <4E324DB4.7060600@fastmail.fm>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 29, 2011 at 04:05:40PM +1000, Greg Banks wrote:
> On 29/07/11 15:32, NeilBrown wrote:
> >
> >Hi Greg,
> >  I saw this patch float past and thought of you... You may not be interested
> >  any more, and it may be a perfectly good patch that does not need any
> >  comment, but I thought I would let you know anyway.
> 
> Thanks Neil.
> 
> I've trimmed the cc list to limit the number of copies Trond and Bruce get:)

I appreciate the thought, but in future please don't trim cc's.

--b.
