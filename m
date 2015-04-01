Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51485 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751964AbbDAT4D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2015 15:56:03 -0400
Date: Wed, 1 Apr 2015 15:56:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: lyndat3@your-mail.com
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: file xfer over NFSv4 with 'sync' ~300X slower than with 'async' ?
Message-ID: <20150401195603.GG3040@fieldses.org>
References: <1427751843.1013981.247256753.2BA43388@webmail.messagingengine.com>
 <1427811676.1314276.247565589.4E14003B@webmail.messagingengine.com>
 <20150401175437.GD3040@fieldses.org>
 <1427911337.1794160.248190485.1F161545@webmail.messagingengine.com>
 <20150401185146.GE3040@fieldses.org>
 <CAHQdGtT2ved_4xRQMyxuWfHAr8mci+unxfXsgv3YX7cJ4NCRBQ@mail.gmail.com>
 <1427915047.1810469.248215805.54189CB6@webmail.messagingengine.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427915047.1810469.248215805.54189CB6@webmail.messagingengine.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2015 at 12:04:07PM -0700, lyndat3@your-mail.com wrote:
> Hi
> 
> > > Yes.  This is a common source of confusion.  In retrospect maybe the
> > > export sync/async option should have had a different name from the
> > > client mount option.--b.
> > >
> > 
> > Do we still need a server 'async' export option? Who is still using
> > NFSv2 for any type of performance-critical work?
> 
> 
> Just to be clear -- MY pebkac was that I'd set the CLIENT mount as 'sync'  --  based on the misunderstanding that write integrity required it 'everywhere' -- on the export AND the mount -- and that 'async' was potentially unsafe.
> 
> The server was always exporting 'sync'.

Yeah, understood, I just meant that if we'd originally named that export
option, I don't know, "trash_me_on_reboot", then you wouldn't have
gotten the "don't use async, it's unsafe" idea, and wouldn't have gotten
into this mess.  But, too late to do anything about that, I guess.

--b.
