From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rpc.mountd --manage-gids breaks on UID differences
Date: Tue, 17 Nov 2009 15:08:31 -0500
Message-ID: <20091117200831.GA3969@fieldses.org>
References: <20091117153928.GA12493@dot.freshdot.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Sander Smeenk <ssmeenk@freshdot.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33163 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbZKQUIA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Nov 2009 15:08:00 -0500
In-Reply-To: <20091117153928.GA12493-N0d2glMUd7m2/GFIlvLUCQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 17, 2009 at 04:39:28PM +0100, Sander Smeenk wrote:
> Aparently this has to do with UIDs being different on the nfs-server and
> the nfs-client as i discovered debugging this problem in two VMs. It's
> quite easy to reproduce and also seems to happen if the user on the
> clientmachine is nonexistant on the servermachine.
> 
> Disabling '--manage-gids' and remouting, restarting or rebooting
> completely fixes the problem. Reintroducing '--manage-gids' breaks it
> again.

Just from those symptoms it sounds to me like rpc.mountd isn't
responding to upcalls when asked about a uid for which there's no
account on the server.  It should be returning a negative response
immediately.

(I assume your server isn't using ldap or nis or something that could
cause lookups of a uid to take a long time?)

--b.

> It appears to me '--manage-gids' is completely broken in this setup, or
> i misunderstand what --manage-gids does, completely.  I haven't tried
> this on newer kernels (2.6.31-14-generic f.e.).
> 
> I do have kernel debug logs during broken and working NFS transactions
> which i got by echoing the correct bitmask to /proc/sys/sunrpc/*debug.
> 
> http://www.freshdot.net/tmp/client-broken-syslog
> http://www.freshdot.net/tmp/server-broken-syslog
> vs
> http://www.freshdot.net/tmp/client-working-syslog
> http://www.freshdot.net/tmp/server-working-syslog
> 
> Is this behaviour intended?
> Hope to hear from you!
> 
> With regards,
> Sander Smeenk.
> -- 
> | When you've seen one shopping center you've seen a mall.
> | 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
