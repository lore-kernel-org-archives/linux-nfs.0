Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:52256 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752251Ab2FSJE0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jun 2012 05:04:26 -0400
Date: Tue, 19 Jun 2012 11:04:13 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 and Kerberos problem in svcgssd
Message-ID: <20120619090413.GO30157@ics.muni.cz>
References: <20120615223028.GS20917@ics.muni.cz>
 <20120618221437.GA13534@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <20120618221437.GA13534@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 18, 2012 at 06:14:37PM -0400, J. Bruce Fields wrote:
> > it seems that -n option for rpc.svcgssd produces file descriptor leaks. It
> > looks like this:
> > 
> > ls -l /proc/25920/fd/
> > total 0
> > lrwx------ 1 root root 64 Jun 16 00:13 29 -> /var/tmp/nfs_0
> > lr-x------ 1 root root 64 Jun 16 00:13 3 -> pipe:[24457591]
> > lrwx------ 1 root root 64 Jun 16 00:13 30 -> /var/tmp/nfs_0
> > l-wx------ 1 root root 64 Jun 16 00:13 4 -> pipe:[24457591]
> > lr-x------ 1 root root 64 Jun 16 00:13 5 -> pipe:[24457592]
> > l-wx------ 1 root root 64 Jun 16 00:13 6 -> pipe:[24457592]
> > lr-x------ 1 root root 64 Jun 16 00:13 7 -> /etc/gssapi_mech.conf
> > lr-x------ 1 root root 64 Jun 16 00:13 8 ->
> > /proc/25920/net/rpc/auth.rpcsec.init/channel
> > lrwx------ 1 root root 64 Jun 16 00:13 9 -> /var/tmp/nfs_0
> > 
> > Is there any known fix for this? It runs quickly from max open files..
> 
> It doesn't look familiar to me.--b.

seems to be KRB problem, however, I thought that it may be a problem in
svcgssd as well.

https://bugzilla.redhat.com/show_bug.cgi?id=761006

-- 
Luká¹ Hejtmánek
