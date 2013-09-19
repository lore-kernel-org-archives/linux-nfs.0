Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm5-vm0.bullet.mail.bf1.yahoo.com ([98.139.213.150]:28477 "EHLO
	nm5-vm0.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751660Ab3ISOVF convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 10:21:05 -0400
References: <1379582806.44080.YahooMailNeo@web140003.mail.bf1.yahoo.com> <20130919131429.GA20422@fieldses.org> <1379597501.95818.YahooMailNeo@web140002.mail.bf1.yahoo.com> <20130919134028.GB20422@fieldses.org> <1379599410.72261.YahooMailNeo@web140001.mail.bf1.yahoo.com> <20130919140846.GC20422@fieldses.org>
Message-ID: <1379600464.91434.YahooMailNeo@web140005.mail.bf1.yahoo.com>
Date: Thu, 19 Sep 2013 07:21:04 -0700 (PDT)
From: Jody Gugelhupf <knueffle@yahoo.com>
Reply-To: Jody Gugelhupf <knueffle@yahoo.com>
Subject: Re: help with nfs export/mount
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20130919140846.GC20422@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

on client side (in order):

sudo mount 192.168.2.3:/ /home/jarvis/Videos/xbmc

no error msg, then trying to access the directory:
ls /home/jarvis/Videos/xbmc/home/user/media/Series
the console does not react, i open a new console and see again 
Sep 19 14:15:56 darkstar kernel: [61095.429346] nfs: server 192.168.2.3 OK
Sep 19 14:17:01 darkstar kernel: [61280.169706] nfs: server 192.168.2.3 not responding, still trying


but i also noticed this (didn't see it before)
Sep 19 16:12:53 darkstar rpc.idmapd[576]: nss_getpwnam: name 'user' not found in domain 'localdomain'



----- Original Message -----
From: J. Bruce Fields <bfields@fieldses.org>
To: Jody Gugelhupf <knueffle@yahoo.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sent: Thursday, September 19, 2013 4:08:46 PM
Subject: Re: help with nfs export/mount

On Thu, Sep 19, 2013 at 07:03:30AM -0700, Jody Gugelhupf wrote:
> on server side I see in dmesg this:
> [8040437.603605] nfsd: last server has exited, flushing export cache
> [8040439.496016] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> [8040439.496035] NFSD: starting 90-second grace period
> 
> on client side i only see:
> Sep 19 13:27:56 darkstar kernel: [61095.429346] nfs: server 192.168.2.3 OK
> Sep 19 13:31:01 darkstar kernel: [61280.169706] nfs: server 192.168.2.3 not responding, still trying
>  is there a way to further debug?

Exactly what commands did you type, and what things happened, in what
order?

--b.

