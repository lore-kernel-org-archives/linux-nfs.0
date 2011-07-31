Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17848 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452Ab1GaSbJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jul 2011 14:31:09 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: Please pull NFS client changes
Date: Sun, 31 Jul 2011 11:30:48 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A777FE7@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20110731182406.GA16470@infradead.org>
References: <1312082377.10882.1.camel@lade.trondhjem.org> <20110731182406.GA16470@infradead.org>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Christoph Hellwig" <hch@infradead.org>
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Christoph Hellwig [mailto:hch@infradead.org]
> Sent: Sunday, July 31, 2011 2:24 PM
> To: Myklebust, Trond
> Cc: Linus Torvalds; linux-fsdevel@vger.kernel.org; linux-
> nfs@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: Please pull NFS client changes
> 
> How does this manage to include the pnfs block code, which only was
> posted
> on the list a few hours before the pull request, and which doesn't
> appear to past testing very well (although the major issue seems to be
> core nfs code)?

The majority of that code has been ready for several weeks and has been
posted several times for review. The main stuff that was addressed in
the last week were smaller issues such as the naming of functions that
are globally visible (i.e. not polluting the kernel namespace), a few
bisectability issues and (in the last iteraction) the lack of a
signed-off-by: from Jim.

I agree that we have to address the bug that Peng found, but that
appears to be linked to the NFSv4.1 back channel, which these patches
did not change.

The other point to note is that the patches do not touch the main
read/write code and only lightly change the pNFS code paths. The impact
of any residual bugs is therefore going to be limited.
