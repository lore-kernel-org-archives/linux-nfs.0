From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: mem leak?
Date: Mon, 1 Sep 2008 17:20:04 -0400
Message-ID: <20080901212003.GA13392@fieldses.org>
References: <200809011153057338447@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Payphone LIOU <lioupayphone@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43997 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751389AbYIAVUF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Sep 2008 17:20:05 -0400
In-Reply-To: <200809011153057338447@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 01, 2008 at 11:53:07AM +0800, Payphone LIOU wrote:
> Hi, linux-nfs :
> 			
>   in nfs-utils1.1.3,  procedure "get_exportlist()" would malloc() some
>   memory for storing the directories and groups for "showmount".
>   obviously those memory are not released when the procedure ends.
>   once mountd received a signal for quiting itself(eg : kill -9 `pidof
>   mountd`), it will call "killer()" for some exiting-works. but those
>   memory allocated in "get_exportlist()" were not released. memory
>   leak? i am not sure. :-(

You're talking about the allocation done on this line?:

	e = (struct exportnode *) xmalloc(sizeof(*e));

>From a quick glance, it looks like the code tries to free that up the
next time get_exportlist() is called, in that first loop over elist.  I
haven't tried to figure out whether that code's correct, though; maybe
you have?  Patches always welcome.

--b.
