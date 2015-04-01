Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:47532 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753310AbbDATEH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2015 15:04:07 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 0A53D20AB9
	for <linux-nfs@vger.kernel.org>; Wed,  1 Apr 2015 15:04:04 -0400 (EDT)
Message-Id: <1427915047.1810469.248215805.54189CB6@webmail.messagingengine.com>
From: lyndat3@your-mail.com
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
In-Reply-To: <CAHQdGtT2ved_4xRQMyxuWfHAr8mci+unxfXsgv3YX7cJ4NCRBQ@mail.gmail.com>
References: <1427751843.1013981.247256753.2BA43388@webmail.messagingengine.com>
 <1427811676.1314276.247565589.4E14003B@webmail.messagingengine.com>
 <20150401175437.GD3040@fieldses.org>
 <1427911337.1794160.248190485.1F161545@webmail.messagingengine.com>
 <20150401185146.GE3040@fieldses.org>
 <CAHQdGtT2ved_4xRQMyxuWfHAr8mci+unxfXsgv3YX7cJ4NCRBQ@mail.gmail.com>
Subject: Re: file xfer over NFSv4 with 'sync' ~300X slower than with 'async' ?
Date: Wed, 01 Apr 2015 12:04:07 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

> > Yes.  This is a common source of confusion.  In retrospect maybe the
> > export sync/async option should have had a different name from the
> > client mount option.--b.
> >
> 
> Do we still need a server 'async' export option? Who is still using
> NFSv2 for any type of performance-critical work?


Just to be clear -- MY pebkac was that I'd set the CLIENT mount as 'sync'  --  based on the misunderstanding that write integrity required it 'everywhere' -- on the export AND the mount -- and that 'async' was potentially unsafe.

The server was always exporting 'sync'.

LT
