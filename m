From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 21 Apr 2008 13:55:48 -0400
Message-ID: <20080421135548.1aa1a4e8@tleilax.poochiereds.net>
References: <480902CA.1070805@redhat.com>
	<48090356.9020703@redhat.com>
	<20080418203225.GD28277@fieldses.org>
	<24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
	<20080421000214.GA5453@fieldses.org>
	<24c1515f0804201749x47bee916y9970fe1102bfb5@mail.gmail.com>
	<20080421021153.GC5453@fieldses.org>
	<20080421070107.454cfad2@tleilax.poochiereds.net>
	<20080421133940.GB28795@fieldses.org>
	<20080421101003.4e9d85a6@tleilax.poochiereds.net>
	<20080421173227.GE4379@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Janne Karhunen <janne.karhunen@gmail.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752902AbYDUR4G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Apr 2008 13:56:06 -0400
In-Reply-To: <20080421173227.GE4379@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 21 Apr 2008 13:32:27 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> > I think that's basically correct, but most modern distros turn it on by
> > default. From the default /etc/sysctl.conf on my fedora box:
> > 
> > net.ipv4.conf.default.rp_filter = 1
> > 
> > ...it's generally a good thing to enable, but there are places where it
> > needs to be disabled. For instance, my Linksys WRT54g is doing firewall
> > duties and has it disabled because the switch ports on it are segmented
> > with VLANs and rp_filter interferes with that.
> 
> Actually, the specific question here is: say you have an ethernet
> interface 192.168.0.1.  Will the kernel deliver a packet that comes from
> the network and has source address 192.168.0.1?
> 

Ahh, I misunderstood then. I'm not sure about that specific situation.
I doubt that rp_filter would prevent that, but there may be some other
mechanism that would.

-- 
Jeff Layton <jlayton@redhat.com>
