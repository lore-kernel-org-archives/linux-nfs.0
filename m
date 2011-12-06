Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39773 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933231Ab1LFLnU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 06:43:20 -0500
MIME-Version: 1.0
In-Reply-To: <20111201072947.GA10329@onthe.net.au>
References: <20111130071319.GA16711@onthe.net.au>
	<1321861008-20611-1-git-send-email-chris@onthe.net.au>
	<20111129082501.GA569@onthe.net.au>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
	<24960.1322643283@redhat.com>
	<20111201004709.GA26085@onthe.net.au>
	<20111201063157.GA495@boyd>
	<20111201072947.GA10329@onthe.net.au>
Date: Tue, 6 Dec 2011 12:43:19 +0100
Message-ID: <CADDYkjQ5G0NnABCJa+TjkTxG8UHSeDJfN9jzm6f5Q5Q-Szuc8g@mail.gmail.com>
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
From: Jacek Luczak <difrost.kernel@gmail.com>
To: Chris Dunlop <chris@onthe.net.au>
Cc: Tyler Hicks <tyhicks@canonical.com>, David Howells <dhowells@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Dave Kleikamp <shaggy@kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        Greg Kroah-Hartman <gregkh@suse.de>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@telemann.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2011/12/1 Chris Dunlop <chris@onthe.net.au>:
[!snip]
>> I'm also not sure about the printk in the NFS case. Instead of littering
>> the logs, we should probably just disallow the stacked filesystem (are
>> we talking about eCryptfs here?) from mounting on top of NFS in the
>> first place.
>
> See other reply: it wasn't a stacked file system.

I've actually hit the same think with NFS on vanilla 2.6.39.4. There
was no stacked fs on top as this host is only running Jenkins master
instance where few jar are on NFS homedir mounted by autofs.

As there's no way I could actually wait for Al patches what is then
the best way to limit this issue (BTW: I was not able to reproduce
this anywhere yet)? The gentle msg info and -EIO sound like good idea
until we will be suck up by black hole.

-Jacek
