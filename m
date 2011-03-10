Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48433 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188Ab1CJK6Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 05:58:25 -0500
Date: Thu, 10 Mar 2011 10:58:21 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Nick Piggin <npiggin@gmail.com>, Nick Piggin <npiggin@kernel.dk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20110310105821.GE22723@ZenIV.linux.org.uk>
References: <20101214220102.GM24828@fieldses.org>
 <20101217180022.GB11515@fieldses.org>
 <20101218020118.GA3179@amd>
 <20101218161609.GA22150@fieldses.org>
 <AANLkTingRv_gtRSctGzMfYrKg02M_sKj97HSQPRm_mA_@mail.gmail.com>
 <20101227234641.GA22248@fieldses.org>
 <20110118204509.GA10903@fieldses.org>
 <AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
 <20110118220817.GF10903@fieldses.org>
 <20110308181320.GA15566@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110308181320.GA15566@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 08, 2011 at 01:13:20PM -0500, J. Bruce Fields wrote:

> Al, do you have this in your queue to look at?  Need me to resend?  Or
> should it take some other route?

It's in queue, but I'd be a lot happier if I understood what's going on
with __d_find_alias() elsewhere.  Namely, in d_splice_alias().  The thing
is, unless I'm missing something we ought to use __d_find_any_alias()
there as well.  Directories really, _really_ should not have more than
one alias.  And what we get is really weird:
	* find (the only) alias
	* if it doesn't exist, create one (OK, no problem)
	* if it does exist and happens to be IS_ROOT and DCACHE_DISCONNECTED,
move it (also fine, modulo rather useless BUG_ON() in there)
	* if it does exist and either isn't IS_ROOT or not DCACHE_DISCONNECTED,
add a new alias and say nothing.

The last part looks very strange.  I'd been staring at the history of this
function and I _think_ it's a rudiment of period when we used that stuff for
non-directories as well.  It used to be directory-only; then Neil had
switched it to non-directories as well (in "Fix disconnected dentries on NFS
exports" back in 2004), adding want_discon argument to __d_find_alias() in
process and using it instead of open-coded equivalent of __d_find_any_alias().
Then, two years later, in "knfsd: close a race-opportunity in d_splice_alias"
he'd made that code directory-only again, at which point we arrived to the
current situation.

Neil, is there some reason I'm missing that makes __d_find_alias() right in
there?  And do we still need the second argument in __d_find_alias()?

Anyway, Bruce's patch goes in tonight's push, but I'd love to see that
mess cleaned up as well or at least explained.
