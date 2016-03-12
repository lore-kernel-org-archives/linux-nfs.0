Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34169 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbcCLKy7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Mar 2016 05:54:59 -0500
Received: by mail-wm0-f45.google.com with SMTP id p65so46764489wmp.1
        for <linux-nfs@vger.kernel.org>; Sat, 12 Mar 2016 02:54:58 -0800 (PST)
Date: Sat, 12 Mar 2016 12:50:46 +0200
From: Leon Romanovsky <leon@leon.nu>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: Bruce Fields <bfields@redhat.com>, Chuck Lever <Chuck.Lever@oracle.com>,
        Doug Ledford <dledford@redhat.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs/rdma: add IPv6 rdma6 support
Message-ID: <20160312105046.GC15703@leon.nu>
Reply-To: leon@leon.nu
References: <56E35820.7070609@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56E35820.7070609@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 11, 2016 at 03:43:28PM -0800, Shirley Ma wrote:
> Add rdma6 option to support NFS/RDMA IPv6.
> Allow both IPv4 and IPv6 to bind same port at the same time,
> and restricts use of the IPv6 socket to IPv6 communication.
> 
> Signed-off-by: shirley.ma@oracle.com

The SOB is not valid.

