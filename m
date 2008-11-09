From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] export dir thru 2 diff path names
Date: Sun, 9 Nov 2008 10:58:31 -0500
Message-ID: <20081109155831.GA24508@fieldses.org>
References: <478B90A1.5000900@bnl.gov>
	<1200330387.7470.11.camel@heimdal.trondhjem.org>
	<478B9A64.5030903@bnl.gov> <49147E79.6000508@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Sev Binello <sev-IGkKxAqZmp0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36926 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755194AbYKIP7e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2008 10:59:34 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KzChH-0000yn-N7
	for linux-nfs@vger.kernel.org; Mon, 10 Nov 2008 02:59:31 +1100
In-Reply-To: <49147E79.6000508-IGkKxAqZmp0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 07, 2008 at 12:44:25PM -0500, Sev Binello wrote:
> Can anyone tell me if it's ok to export the same file system
> through 2 different paths ( one is a link) ?

I actually don't know.  You could try it and tell us what you find
out....

If you're exporting something *containing* the symlink and expecting the
client to traverse into the filesystem, be aware that symlinks over NFS
are actually interpreted (and followed) on the client--so they're
interpreted as *client-side* paths, not server-side.

If the path you're exporting is itself a symlink--it probably depends on
how nfs-utils treats symlinks found in /etc/exports.  I'd have to try it
or check the code.

Another way to export the filesystem in two different places would be
with mount --bind.

--b.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

