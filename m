Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:54908 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733AbaA3XRc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jan 2014 18:17:32 -0500
Date: Thu, 30 Jan 2014 18:17:03 -0500
From: Jim Rees <rees@umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Weston Andros Adamson <dros@monkey.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Message-ID: <20140130231703.GA19132@umich.edu>
References: <20140130172451.7a354ce4@notabene.brown>
 <42E058FF-5672-4E07-8AFC-32C0933A01F8@monkey.org>
 <4D91FF8C-313D-4F02-858B-476ABEB46987@monkey.org>
 <20140130185206.GA12456@fieldses.org>
 <20140131095036.3a11f93b@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140131095036.3a11f93b@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown wrote:

  Though I do wonder if it would every be used.  Would *anyone* build nfs-utils
  with a non-standard prefix, and also get systemd to manage that version?

Some of the other paths, like this one (note the typo too) might need to
change.

/usr/lib/systemd/scritps/nfs-utils_env.sh
