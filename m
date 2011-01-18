Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aa.linuxbox.com ([134.215.213.37]:4367 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122Ab1ARSrP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 13:47:15 -0500
Date: Tue, 18 Jan 2011 13:46:30 -0500 (EST)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Daniel Muntz <Daniel.Muntz@emc.com>, rees@umich.edu,
        androsadamson@gmail.com, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@panasas.com>
Message-ID: <2129226927.80.1295376390168.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1295375921.3746.27.camel@heimdal.trondhjem.org>
Subject: Re: 4.1 no-pnfs mount option?
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

Isn't by mount a plausible way to select for pnfs independent of debugging?  Is it assured that a client administrator would never reasonably wish to do this?

Matt

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> > 
> > Such a mount option could be useful for dealing with buggy servers
> (pnfs-wise) so you
> > could mount one server with pnfs and another without.
> 
> You can find ways around that. Just use 2 clients: one with pnfs
> switched on, and one with it off.
> 
> I really don't want to introduce mount options upstream unless they
> are
> useful in the long term. One off usefulness does not pass that test.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

Matt Benjamin

The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
