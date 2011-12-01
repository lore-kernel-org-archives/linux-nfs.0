Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45451 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab1LAJ5z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 04:57:55 -0500
Received: by eaak14 with SMTP id k14so1896662eaa.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2011 01:57:54 -0800 (PST)
Message-ID: <4ED74F9E.3030602@tonian.com>
Date: Thu, 01 Dec 2011 11:57:50 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: tao.peng@emc.com
CC: bharrosh@panasas.com, bergwolf@gmail.com, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH-RESEND 4/4] pnfsblock: do not ask for layout in pg_init
References: <1322888194-3039-1-git-send-email-bergwolf@gmail.com> <4ED62857.7090804@tonian.com> <CA+a=Yy5BYoxVWM+4C6ORex5aOZcLAbUmhY6XE=wBsreGVG7GAA@mail.gmail.com> <4ED6D5D8.9010801@panasas.com> <F19688880B763E40B28B2B462677FBF805E5043E4B@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805E5043E4B@MX09A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-12-01 07:05, tao.peng@emc.com wrote:
> 1. remove the limit on IO_MAX at .pg_test.
> 2. ask for layout at .pg_doio for the size of current IO desc
> 3. if server returns short layout, split nfs_read/write_data or desc and issue the pagelist covered by lseg.
> 4. do 2 and 3 in a loop until all pages in current desc is handled.

Sounds reasonable to me.

Benny
