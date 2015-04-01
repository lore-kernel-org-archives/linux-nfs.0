Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:53234 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750924AbbDAUYd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2015 16:24:33 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id ABA29209C0
	for <linux-nfs@vger.kernel.org>; Wed,  1 Apr 2015 16:24:29 -0400 (EDT)
Message-Id: <1427919872.1831768.248246417.7CA8045D@webmail.messagingengine.com>
From: lyndat3@your-mail.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: file xfer over NFSv4 with 'sync' ~300X slower than with 'async' ?
Date: Wed, 01 Apr 2015 13:24:32 -0700
In-Reply-To: <20150401195603.GG3040@fieldses.org>
References: <1427751843.1013981.247256753.2BA43388@webmail.messagingengine.com>
 <1427811676.1314276.247565589.4E14003B@webmail.messagingengine.com>
 <20150401175437.GD3040@fieldses.org>
 <1427911337.1794160.248190485.1F161545@webmail.messagingengine.com>
 <20150401185146.GE3040@fieldses.org>
 <CAHQdGtT2ved_4xRQMyxuWfHAr8mci+unxfXsgv3YX7cJ4NCRBQ@mail.gmail.com>
 <1427915047.1810469.248215805.54189CB6@webmail.messagingengine.com>
 <20150401195603.GG3040@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Yeah, understood, I just meant that if we'd originally named that export
> option, I don't know, "trash_me_on_reboot", then you wouldn't have
> gotten the "don't use async, it's unsafe" idea, and wouldn't have gotten
> into this mess.  But, too late to do anything about that, I guess.


I'm surprised at how ineffective I was at finding & understanding the whole business to begin with.

If not for Trond's comments and stumbling on that reference re: NFS sync/async issues on "not-my-distro", I'd still be thrashing around.

A bunch of other people responding on the issue weren't clear about, or aware of, the issue.  At least not that I was hearing.  Entirely possible that I was asking the wrong question the wrong way, so I'll take my share of it.

Just looking at the decade+ of "my NFS is slow. why?" posts & comments  I found & read, having this async/sync biz documented & easy to find for normal humans might be helpful.  If it's there I sure as heck missed it.

My two cents.

Thanks again!

LT
