From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] bug in nfs-utils support/misc/tcpwrapper.c
Date: Mon, 5 May 2008 11:11:05 -0400
Message-ID: <20080505151105.GC8259@fieldses.org>
References: <alpine.DEB.0.99999.0805030130590.9075@zaphod.blinkenlights.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, steved@redhat.com
To: Sten Spans <sten-4ZM2p5qjiQFChlZ7zSldDQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48732 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288AbYEEPQa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 11:16:30 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jt2QT-0004l1-1G
	for linux-nfs@vger.kernel.org; Tue, 06 May 2008 01:16:25 +1000
In-Reply-To: <alpine.DEB.0.99999.0805030130590.9075-bOEg3dqIyRvlQVwb/tpZ4uvFKoSm8Hlx@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 03, 2008 at 01:49:20AM +0200, Sten Spans wrote:
> 
> I've been trying to get /etc/netgroup support going on
> a machine serving nfs mounts to hosts located in various
> .nl netblocks. Managing hosts this way greatly simplifies
> hosts.allow and exports management, easily worth any slowdowns
> during mounting.
> 
> I did notice a small problem in the tcpwrapper support:
> (resulting in errors from mountd)
> 
> 127    /* Check the official name first. */
> 128    if (hosts_ctl(daemon, "", hp->h_name, ""))
> 129         return 1;
> 
> this supplies the resolved hostname in the address field of hosts_ctl
> which doesn't work. Changing it to:
> 
> if (hosts_ctl(daemon, hp->h_name, "", ""))
> 
> does work as expected. The h_aliases check on line 133 probably needs
> the same change to work as expected.

Yep; looks like a clear bugfix.  (If you have a moment to generate a
patch (with diff -u) showing both changes, that would probably help
Steve.)--b.

> 
> -- 
> Sten Spans
> 
> "There is a crack in everything, that's how the light gets in."
> Leonard Cohen - Anthem
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
> Don't miss this year's exciting event. There's still time to save $100. 
> Use priority code J8TL2D2. 
> http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>     http://vger.kernel.org/vger-lists.html#linux-nfs
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

