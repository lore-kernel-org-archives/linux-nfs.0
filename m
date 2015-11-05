Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:43897 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756818AbbKEVyq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 16:54:46 -0500
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <jlayton@poochiereds.net>
Subject: Re: [PATCH RFCv2] nfsd: fix race with open / open upgrade stateids
References: <1446657225-72903-1-git-send-email-aweits@rit.edu>
	<20151105212108.GH9210@fieldses.org>
Date: Thu, 05 Nov 2015 16:54:45 -0500
In-Reply-To: <20151105212108.GH9210@fieldses.org> (J. Bruce Fields's message
	of "Thu, 5 Nov 2015 16:21:08 -0500")
Message-ID: <m2a8qsru1m.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Is there some lock imbalance?:

Hmmmm, I'll have to poke at that a bit.

> When you send a v2 patch, would you mind also describing what's changed?
> If you stick the description here (between the --- and the diff), it'll
> be discarded when git applies the patch (which is what we want).

Ah. In this case, v1 missed unlocking the rwsem if nfs4_upgrade_open()
returned status.

> Is there's some particular point that you thought was confusing here?
> Then I'm fine with highlighting that.  But I don't want to routinely add
> these block comments on every little function.

Ok.

> Code looks OK, though.  (And I don't spot the locking problem on a quick
> skim...).

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
