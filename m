Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao107.cox.net ([68.230.240.59]:51738 "EHLO
	eastrmmtao107.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474Ab1BGUwm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Feb 2011 15:52:42 -0500
Date: Mon, 7 Feb 2011 14:53:06 -0600
From: Tom Haynes <tdh@excfb.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tom Haynes <tdh@excfb.com>, linux-nfs@vger.kernel.org
Subject: Re: Debugging mount failure with netgroup
Message-ID: <20110207205306.GA13731@adept.internal.excfb.com>
References: <20110207195609.GA13225@adept.internal.excfb.com>
 <20110207201202.GA3055@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110207201202.GA3055@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mon, Feb 07, 2011 at 03:12:02PM -0500, J. Bruce Fields wrote:
> > What can I do to further triage this?
> 
> Alas, I've never used netgroups, much less tried to debug problems with
> them.... Have you tried looking at the nis traffic over "lo" to see if
> mountd's doing the right queries?  You could also try seeing if adding
> "-dall" to the rpc.mountd commandline turns up any useful debugging.

[tdh@adept ~]> sudo tshark -i lo
Running as user "root" and group "root". This could be dangerous.
Capturing on lo
  0.000000 192.168.2.108 -> 192.168.2.108 DNS Standard query PTR 105.2.168.192.in-addr.arpa
  0.002862 192.168.2.108 -> 192.168.2.108 DNS Standard query response PTR wont.internal.excfb.com
  0.003455 192.168.2.108 -> 192.168.2.108 DNS Standard query A wont.internal.excfb.com
  0.003499 192.168.2.108 -> 192.168.2.108 DNS Standard query AAAA wont.internal.excfb.com
  0.003819 192.168.2.108 -> 192.168.2.108 DNS Standard query response A 192.168.2.105
  0.003939 192.168.2.108 -> 192.168.2.108 DNS Standard query response
  0.004427 192.168.2.108 -> 192.168.2.108 DNS Standard query A wont.internal.excfb.com
  0.004761 192.168.2.108 -> 192.168.2.108 DNS Standard query response A 192.168.2.105
  7.472292 192.168.2.108 -> 192.168.2.108 YPSERV V2 DOMAIN Call
  7.472413 192.168.2.108 -> 192.168.2.108 YPSERV V2 DOMAIN Reply (Call In 9)

The above seems to suggest that the host lookup went fine.

-dall:

Feb  7 14:35:27 adept mountd[13285]: check_default: access by 192.168.2.105 ALLOWED (cached)
Feb  7 14:35:27 adept mountd[13285]: Received NULL request from 192.168.2.105
Feb  7 14:35:27 adept mountd[13285]: check_default: access by 192.168.2.105 ALLOWED (cached)
Feb  7 14:35:27 adept mountd[13285]: Received NULL request from 192.168.2.105
Feb  7 14:35:27 adept mountd[13285]: check_default: access by 192.168.2.105 ALLOWED (cached)
Feb  7 14:35:27 adept mountd[13285]: Received MNT3(/fooper) request from 192.168.2.105
Feb  7 14:35:27 adept mountd[13285]: refused mount request from 192.168.2.105 for /fooper (/fooper): unmatched host



> 
> After that, I don't know, I suppose I'd start looking at the mountd
> source....

Yeah, I'm not sure if I can do that. :->

I did google and did not find much on netgroups - but I did find
a bunch on "unmatched host".

It seems to be black magic from some of the answers.

And I agree:

1) Modified the export:
[root@adept /]# more /etc/exports 
/fooper   @adeptya(rw,insecure,no_root_squash,sync)

2) Did other mumbo-jumbo

3) Really, really did not want to reboot.

4) service nfs stop ; exportfs ; service nfs start

And that last one worked!

Feb  7 14:44:31 adept mountd[13712]: Received MNT3(/fooper) request from 192.168.2.105
Feb  7 14:44:31 adept mountd[13712]: authenticated mount request from wont.internal.excfb.com:972 for /fooper (/fooper)
Feb  7 14:44:31 adept mountd[13712]: nfsd_fh: inbuf '@adeptya 7 \x0100060000000000a9a3be796f4c43878b99ea75025e5384'
Feb  7 14:44:31 adept mountd[13712]: nfsd_fh: found 0x20da950 path /fooper

Thanks

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Tom Haynes
ex-cfb
