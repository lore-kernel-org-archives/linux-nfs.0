Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51733 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418Ab1HHQXb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Aug 2011 12:23:31 -0400
Date: Mon, 8 Aug 2011 12:23:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: mtk.manpages@gmail.com
Cc: linux-man@vger.kernel.org, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Subject: Re: nfsservctl(2)
Message-ID: <20110808162328.GD904@fieldses.org>
References: <20110808162232.GC904@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110808162232.GC904@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The nfsservctl system call has long been superceded by a better
interface, and is finally getting removed in the 3.1 kernel.

I'm not sure what to do with the man page--remove it, or add a note
saying it's gone from recent kernels?  Do you have something you
generally do in such cases?

It's been replaced by a set of files in the nfsd filesystem, which is
documented in nfsd(7).  That man page looks sufficiently up-to-date to
cover the functionality previous provided by nfsservctl.  (Though I only
skimmed it quickly.  It might be worth a more careful review some day.)

--b.

(Argh, sorry, resending with cut-n-pasted addresses de-obfuscated.)
