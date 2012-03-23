Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:60067 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755677Ab2CWSCw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Mar 2012 14:02:52 -0400
Date: Fri, 23 Mar 2012 14:02:47 -0400
From: Jim Rees <rees@umich.edu>
To: Bruno Silva <bs@cin.ufpe.br>
Cc: Lev Solomonov <solo@tonian.com>, linux-nfs@vger.kernel.org
Subject: Re: About pNFS installation process.
Message-ID: <20120323180247.GA2815@umich.edu>
References: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
 <CAOdHTRB5tfXvdEprnUpfswdr7Afq-cOvsqj2VicLipKc2sOK9w@mail.gmail.com>
 <CAAJC9VbvRm49iW2jFUfVqw4k20hPbLfrUr_Wm=pHLmD_23WJew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAAJC9VbvRm49iW2jFUfVqw4k20hPbLfrUr_Wm=pHLmD_23WJew@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Blkmapd is finding your iscsi devices, but can't create the mapped device
for some reason.  I suspect the geometry is wrong but you'd have to do some
debugging to figure out exactly why.

I guess we should fix or get rid of pretty_sig.

Date: Thu, 2 Dec 2010 09:41:26 -0500
From: Jim Rees <rees@umich.edu>
Subject: Re: [PATCH 4/5] various minor cleanups
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>

...

I am glad you are paying attention!  I am aware of the shortcomings of
pretty_sig().  In addition to the problems you noted, it also assumes that a
signature over 8 bytes long is representable as a text string, which is not
guaranteed.  The code it replaced was worse.

I put this in because for debugging I need to be able to follow a signature
all the way from my EMC server to the devmapper.  pretty_sig() simply prints
the signature in a way that I can match it up with the signature on the
server.

I don't want to spend a lot of time on this, but I also am uneasy leaving
EMC-specific code in nfs-utils, especially since it can blow up if you use
it against a non-EMC server.  My inclination is to remove this debugging
code when I no longer need it.  I guess at the very least I should put in a
comment.  I am open to suggestions.
