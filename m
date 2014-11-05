Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gproxy7-pub.mail.unifiedlayer.com ([70.40.196.235]:36254 "HELO
	gproxy7-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751977AbaKEBak (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Nov 2014 20:30:40 -0500
From: Henrique Martins <linux@martins.cc>
To: Steve Dickson <SteveD@redhat.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: F20 nfs-utils exportfs patch
In-reply-to: <54591385.2080007@RedHat.com>
References: <14393.1409936528@monster.martins.cc> <15531.1414780435@monster.martins.cc> <54591385.2080007@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 04 Nov 2014 17:30:32 -0800
Message-ID: <16217.1415151032@monster.martins.cc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Missed these comments in the middle of the patch ...

> Just curious as to why these changes... What does  D_PARSE do that
> D_GENERAL does not?

D_PARSE, and L_WARNING, don't cause xlog to return an error,
D_GENERAL and L_ERROR do.  An error from xlog which will
cause nfsd to error out and not start.

I changed L_ERROR with L_WARNING, but there was no
D_WARNING def or similar so I went with D_PARSE instead of
adding that one.

> When testing the patch, I notice two "Failed to resolve" warning messages
> are logged for each export... Its not because of this patch but
> I wounder how that could be cleaned up a bit....

Hopefully you solved that, otherwise I would have to hunt on
which machine I generated those patches, if I didn't wipe
out the rpmbuild environment yet..

-- Henrique
