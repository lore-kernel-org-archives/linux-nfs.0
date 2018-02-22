Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41832 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751565AbeBVAee (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Feb 2018 19:34:34 -0500
Date: Wed, 21 Feb 2018 19:34:34 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kenneth Dsouza <kdsouza@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Add support for -R option in nfs4_getfacl so we can list
 the ACLs of all files and directories recursively.
Message-ID: <20180222003434.GD6535@fieldses.org>
References: <20180207213055.18211-1-kdsouza@redhat.com>
 <20180221225548.GC6535@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180221225548.GC6535@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 21, 2018 at 05:55:48PM -0500, J. Bruce Fields wrote:
> People have been request recursive operation and I keep not getting
> around to it, thanks for doing this.
> 
> How are you testing this?

Also, on top of this patch (which I've committed, thanks) it might also
be nice to:

	- add -L and -P options to choose whether you want to follow
	  symlinks, as "getfacl" does.  I think this is just a matter of
	  passing the right flags to nftw.
	- switch to using getopt instead of parsing the flags by hand
	  (looks like nfs4_setfacl already does this).

--b.
