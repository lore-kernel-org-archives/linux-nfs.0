From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 03/14] nfsd4: remove redundant "if" in
	nfs4_preprocess_stateid_op
Date: Wed, 11 Mar 2009 15:49:43 -0400
Message-ID: <20090311194943.GI13540@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org> <1236731222-3294-2-git-send-email-bfields@fieldses.org> <1236731222-3294-3-git-send-email-bfields@fieldses.org> <1236731222-3294-4-git-send-email-bfields@fieldses.org> <49B7100E.2000209@cn.fujitsu.com> <20090311012346.GB4495@fieldses.org> <49B7133E.10804@cn.fujitsu.com> <49B7FD6B.5060203@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yang Hongyang <yanghy@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:54509 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbZCKTtw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2009 15:49:52 -0400
In-Reply-To: <49B7FD6B.5060203@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 11, 2009 at 08:05:31PM +0200, Benny Halevy wrote:
> On Mar. 11, 2009, 3:26 +0200, Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
> > J. Bruce Fields wrote:
> >> On Wed, Mar 11, 2009 at 09:12:46AM +0800, Yang Hongyang wrote:
> >>> J. Bruce Fields wrote:
> >>>> From: J. Bruce Fields <bfields@citi.umich.edu>
> >>>>
> >>>> Note that we exit this first big "if" with stp == NULL iff we took the
> >>>                                                                                         ^^ typo
> >> The "iff"?  That's short for "if and only if".  I can try to get out of
> >> the "iff" habit if it's too obscure.
> > 
> > Sorry for mis-understanding,My pool englishT_T Maybe "if and only if"
> > are more understandable.
> 
> Although using this iffy math/cs school lingo does not seem too obscure
> to me (one can find it easily on the net, e.g.
> http://www.tfd.com/?Word=iff), as a non-native English speaker I'd be
> inclined to simplify commentary language as much as possible and
> refrain from using acronyms if they are not obvious to the linux
> developers community.

OK.--b.
