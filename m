Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:38512 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755685Ab2BLSDU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Feb 2012 13:03:20 -0500
Message-ID: <4F37FECD.9030500@panasas.com>
Date: Sun, 12 Feb 2012 20:02:53 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <bjschuma@netapp.com>
CC: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 19/21] NFS: Convert v4 into a module
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com> <1328911325-1566-19-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-19-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/11/2012 12:02 AM, bjschuma@netapp.com wrote:
> The module will be created in the same directory as nfs.ko.  You need to
> run `modprobe nfs4` before you can use it.
> 

Can we do this mod_alias and autoloading magic like we do with 
LD drivers, so if NFSv4 is requested it is automatically loaded
by Kernel. 

This way the impact on user-mode will be minimal.

Thanks
Boaz
