From: "Adam Olsen" <arolsen@gmail.com>
Subject: Re: NFS+GD issues on kernel 2.6.24, but not 2.6.22
Date: Thu, 15 May 2008 14:15:51 -0600
Message-ID: <2473b43f0805151315m3547bc17o57ca14c46a636671@mail.gmail.com>
References: <2473b43f0805150706g5be9918cu3c77d9135cded912@mail.gmail.com>
	 <20080515084610.4e5161bc@tupile.poochiereds.net>
	 <2473b43f0805150855o59a14e34h82b20f847c53f392@mail.gmail.com>
	 <1210876652.17301.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Jeff Layton" <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:30738 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764646AbYEOUPw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2008 16:15:52 -0400
Received: by wr-out-0506.google.com with SMTP id c48so306659wra.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2008 13:15:52 -0700 (PDT)
In-Reply-To: <1210876652.17301.3.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 15, 2008 at 12:37 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
>  Looks as if you've got a 32-bit application that doesn't like 64-bit
>  inode numbers. Try booting with the kernel parameter
>  'nfs.enable_ino64=0'.

Ok, tried that.  It's still a no go.

-- 
Adam Olsen
SendOutCards.com
http://www.vimtips.org
http://last.fm/user/synic
