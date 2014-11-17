Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60587 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751520AbaKQTEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Nov 2014 14:04:25 -0500
Message-ID: <546A46B1.7040902@RedHat.com>
Date: Mon, 17 Nov 2014 14:04:17 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@primarydata.com>, chuck.lever@oracle.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 0/2] nfsdcltrack: don't use libsqlite3 functions that
 are too new
References: <1416249135-18736-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416249135-18736-1-git-send-email-jlayton@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/17/2014 01:32 PM, Jeff Layton wrote:
> Chuck was having a problem building nfsdcltrack on a RHEL6 era box, due
> to the fact that the libsqlite3 library there was too old. While we
> could play games with autoconf, it's just easier to use older library
> functions in these places so that we don't have to.
> 
> Jeff Layton (2):
>   nfsdcltrack: use sqlite3_close instead of sqlite3_close_v2
>   nfsdcltrack: use sqlite3_errmsg instead of sqlite3_errstr
> 
>  utils/nfsdcltrack/sqlite.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
Both have been committed! Happy Compiles! ;-) 

steved.
