Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm41-vm9.bullet.mail.bf1.yahoo.com ([216.109.114.138]:22062
	"EHLO nm41-vm9.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751660Ab3ISOKR convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 10:10:17 -0400
References: <1379582806.44080.YahooMailNeo@web140003.mail.bf1.yahoo.com> <20130919131429.GA20422@fieldses.org> <1379597501.95818.YahooMailNeo@web140002.mail.bf1.yahoo.com> <20130919134028.GB20422@fieldses.org>
Message-ID: <1379599410.72261.YahooMailNeo@web140001.mail.bf1.yahoo.com>
Date: Thu, 19 Sep 2013 07:03:30 -0700 (PDT)
From: Jody Gugelhupf <knueffle@yahoo.com>
Reply-To: Jody Gugelhupf <knueffle@yahoo.com>
Subject: Re: help with nfs export/mount
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20130919134028.GB20422@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

on server side I see in dmesg this:
[8040437.603605] nfsd: last server has exited, flushing export cache
[8040439.496016] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[8040439.496035] NFSD: starting 90-second grace period

on client side i only see:
Sep 19 13:27:56 darkstar kernel: [61095.429346] nfs: server 192.168.2.3 OK
Sep 19 13:31:01 darkstar kernel: [61280.169706] nfs: server 192.168.2.3 not responding, still trying
 is there a way to further debug?

----- Original Message -----

From: J. Bruce Fields <bfields@fieldses.org>
To: Jody Gugelhupf <knueffle@yahoo.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sent: Thursday, September 19, 2013 3:40:28 PM
Subject: Re: help with nfs export/mount

On Thu, Sep 19, 2013 at 06:31:41AM -0700, Jody Gugelhupf wrote:
> Thanks also for your response, I have tried you suggestion of: 
>     /home/user/media/ 192.168.2.0/24(rw,insecure,crossmnt,no_root_check,no_subtree_check)
> 
> but got an error that 'no_root_check' was unknown, so i suppose just a type and meant was:
>     /home/user/media/ 192.168.2.0/24(rw,insecure,crossmnt,no_root_squash,no_subtree_check)
> 
> 
> but still it does not work, not only on ubuntu but also not on xbmc (openelec/rpi)

Could you explain exactly how it fails?

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

