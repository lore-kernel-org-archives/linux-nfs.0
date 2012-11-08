Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42578 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118Ab2KHMem (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Nov 2012 07:34:42 -0500
Date: Thu, 8 Nov 2012 07:34:41 -0500
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, faisaman4@gmail.com
Subject: Re: implement backchannel security negotation
Message-ID: <20121108123441.GC22735@fieldses.org>
References: <1352335463-29084-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1352335463-29084-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 07, 2012 at 07:44:18PM -0500, J. Bruce Fields wrote:
> This is an incomplete implementation of the (mandatory) NFSv4.1
> backchannel security negotation, only enough to handle auth_unix and
> auth_null; auth_gss will need more work.

And I've also pushed out corresponding pynfs tests to

	git://linux-nfs.org/~bfields/pynfs.git

Fred, could you please pull the master branch from there?  It's got a
hundred-some commits outstanding at this point.

--b.
