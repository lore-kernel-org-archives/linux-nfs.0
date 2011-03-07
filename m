Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38396 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753307Ab1CGSV5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Mar 2011 13:21:57 -0500
Date: Mon, 7 Mar 2011 13:21:56 -0500
To: Ivo =?utf-8?Q?P=C5=99ikryl?= <prikryl@eurosat.cz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Possible NFSv4 locking bug
Message-ID: <20110307182156.GA8104@fieldses.org>
References: <201103070059.28304.prikryl@eurosat.cz>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <201103070059.28304.prikryl@eurosat.cz>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 07, 2011 at 12:59:28AM +0100, Ivo Přikryl wrote:
> Hello, 
> 
> just booted MDV 2010.2 with custom build 2.6.38 RC3 kernel, NFS4 server patched with your patch. 
> So far it seems to be running just fine. No file descriptor wasted..
> 
> server#cat /proc/sys/fs/file-nr
> 960     0       1231794
> 
> I will give it more time to observe..
> 
> 
> I can also confirm, that before it was impossible to umount the volume after file descriptors leakage. 
> If you want me to test anything regarding this issue, I have system ready.

Thanks for the report!

(Minor complaint: in future if you mean to send mail to me, please send
it to me specifically and cc: the list, don't send it to the list only.)

--b.
