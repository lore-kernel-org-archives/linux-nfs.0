Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35331 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdCHXQO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Mar 2017 18:16:14 -0500
Received: by mail-qk0-f180.google.com with SMTP id v125so92147962qkh.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Mar 2017 15:16:06 -0800 (PST)
Date: Wed, 8 Mar 2017 18:16:03 -0500
From: John Bazik <john_bazik@brown.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: access(2) inaccurately reports execute permissions
Message-ID: <20170308231602.GR27384@cs.brown.edu>
References: <20170308215058.GO27384@cs.brown.edu>
 <20170308220723.GA4902@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170308220723.GA4902@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I hate to say this, but I think there have been some relevant changes
> since then, is it possible to retry with a more recent kernel?

If it's fixed, that's great.  I won't be able to try a newer kernel for
a while.

> 	- watch the traffic in wireshark, check that the ACCESS calls on
> 	  the wire agree with what your test program is seeing.

Looks like the server response is OK:

NFS	234	V4 Reply (Call In 36) ACCESS, [Access Denied: MD XT], [Allowed: RD XE]

> 	- to verify that your server is mapping to the correct user, try
> 	  touching a new file after su'ing and acquiring kerberos
> 	  credentials, and check who the new file is owned by.

root@radio:/testmnt# ./runas -k test314 touch tmp/foobar
root@radio:/testmnt# ls -l tmp/foobar
-rw-rw---- 1 test314 user-test314 0 Mar  8 18:14 tmp/foobar

John
