Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.chillheid.nl ([195.189.117.195]:13395 "EHLO
	mail.chillheid.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312Ab2BCXY2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Feb 2012 18:24:28 -0500
From: Koen Wilde <koen@chillheid.nl>
Subject: Re: oops when copying a file from a nfs mount
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
In-Reply-To: <20120203230811.GH2999@fieldses.org>
References: <20120203223604.98C91405DC@mail.chillheid.nl> <20120203230811.GH2999@fieldses.org>
Date: Sat, 04 Feb 2012 00:24:27 +0100
Message-Id: <20120203232427.20B21405DC@mail.chillheid.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 3 Feb 2012 18:08:11 -0500, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> Is this really the start of the trace, or were there any lines before?
> 

This is really the start of the trace as it appears in syslog's logs. On
the physical screen it had some extra lines on top though (I'm typing this
over from a photo):

    BUG: unable to handle kernel NULL pointer dereference at   (null)
    IP: [<c01f3c00>] page_address+0x10/0xe0
    << continuing from here with the *pde line >>

> But I take it you're comfortable building a kernel from source?  If so,
> getting a stable git repo, then:
> 
> 	git checkout v3.2.2
> 	git revert 628fc192adbaae0c6178b9015fb916ce61d72b36
> 
> and then testing the resulting kernel--it'd be interesting to know if
> the bug goes away.

Sure, I can build a kernel from source:) I'll get back to you with the
results.

-- Koen
