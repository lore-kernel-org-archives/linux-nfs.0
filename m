Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:51660 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbEABz1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 21:55:27 -0400
Date: Fri, 1 May 2015 02:55:24 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150501015524.GO889@ZenIV.linux.org.uk>
References: <20150421215417.GE13782@fieldses.org>
 <553781E2.1000900@gmail.com>
 <20150422150703.GA1247@fieldses.org>
 <20150423094431.1a8aa68b@notabene.brown>
 <5538EB18.7080802@gmail.com>
 <20150424130045.6bbdb2f9@notabene.brown>
 <553E2784.6020906@gmail.com>
 <20150429125728.69ddfc6c@notabene.brown>
 <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150430075225.21a71056@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 30, 2015 at 07:52:25AM +1000, NeilBrown wrote:

> An alternative might be to stop using lookup_one_len, and use kern_path()
> instead.  Or kern_path_mountpoint if we don't want to cross a mountpoint.

NAK.  This is a monumentally bad idea - please, do not do it.  Not to mention
anything else, kern_path() is a _lot_ heavier, including much worse stack
footprint.
