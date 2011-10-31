Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11960 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933500Ab1JaPtZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 11:49:25 -0400
Subject: Re: [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org, bhalevy@tonian.com, Peng Tao <peng_tao@emc.com>
Date: Mon, 31 Oct 2011 11:49:08 -0400
In-Reply-To: <1320074136-3087-2-git-send-email-bergwolf@gmail.com>
References: <1320074136-3087-1-git-send-email-bergwolf@gmail.com>
	 <1320074136-3087-2-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320076148.4714.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-31 at 08:15 -0700, Peng Tao wrote: 
> For blocklayout, we need to issue layoutreturn to return layouts when
> handling CB_RECALL_ANY.

Why?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

