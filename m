Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47665 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755630Ab2ALVpO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 16:45:14 -0500
Message-ID: <1326404697.10529.1.camel@lade.trondhjem.org>
Subject: Re: [PATCH-v2 3/9] pnfsblock: move find lock page logic out of
 bl_write_pagelist
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu,
        Peng Tao <peng_tao@emc.com>, Benny Halevy <bhalevy@tonian.com>
Date: Thu, 12 Jan 2012 16:44:57 -0500
In-Reply-To: <1326381528-2232-4-git-send-email-bergwolf@gmail.com>
References: <1326381528-2232-1-git-send-email-bergwolf@gmail.com>
	 <1326381528-2232-4-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-01-12 at 23:18 +0800, Peng Tao wrote: 
> Also avoid unnecessary lock_page if page is handled by others.

Ditto...
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

