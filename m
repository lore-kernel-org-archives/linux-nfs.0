Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:52521 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751172Ab1IUXkE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 19:40:04 -0400
From: =?utf-8?q?R=C3=BCdiger_Meier?= <sweet_f_a@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: Re: processes hanging in state D when reading from nfs
Date: Thu, 22 Sep 2011 01:40:00 +0200
References: <201108272122.53243.sweet_f_a@gmx.de> <20110920135252.GB12422@fieldses.org>
In-Reply-To: <20110920135252.GB12422@fieldses.org>
Content-Type: text/plain;
  charset="utf-8"
Message-Id: <201109220140.01082.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tuesday 20 September 2011, J. Bruce Fields wrote:
> On Sat, Aug 27, 2011 at 09:22:53PM +0200, Rüdiger Meier wrote:
> > I've got an annoying problem with my nfs4 clients.
> > Lately I see many processes hanging in state D when reading from
> > nfs mount. Sometimes they can be killed sometimes not.
>
> Is this still happening?

Yes, allthough we've managed to avoid the "dangerous" things.
Sometimes we have also probs like the other current thread
"Writing / Locking problem with NFSv4".

Moreover I've got issues with wrong file permissions of newly created 
files. Mostly when using make: The first make failes and you see some 
objects files with strange permissions. If you watch these files on 
other clients then they are ok. Then the second make finishes 
successful.
I'm still suspecting the damn readdir cache changes in 2.6.37.

> Running wireshark and watching the network traffic may sometimes give
> an idea whether the client or server is to blame.

I should do that but somehow I'm a bit tyred of debugging my NFS issues 
after doing it the whole last year just to get one thing fixed and run 
into another issue. Maybe I first try a current kernel, hoping that 
things are getting better without doing anything.

cu,
Rudi
