Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41990 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751Ab3ISNk3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 09:40:29 -0400
Date: Thu, 19 Sep 2013 09:40:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jody Gugelhupf <knueffle@yahoo.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: help with nfs export/mount
Message-ID: <20130919134028.GB20422@fieldses.org>
References: <1379582806.44080.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <20130919131429.GA20422@fieldses.org>
 <1379597501.95818.YahooMailNeo@web140002.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1379597501.95818.YahooMailNeo@web140002.mail.bf1.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
