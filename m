From: "Adam Olsen" <arolsen@gmail.com>
Subject: Re: NFS+GD issues on kernel 2.6.24, but not 2.6.22
Date: Thu, 15 May 2008 14:00:01 -0600
Message-ID: <2473b43f0805151300q19d23bddy612e1978864669de@mail.gmail.com>
References: <2473b43f0805150706g5be9918cu3c77d9135cded912@mail.gmail.com>
	 <20080515084610.4e5161bc@tupile.poochiereds.net>
	 <2473b43f0805150855o59a14e34h82b20f847c53f392@mail.gmail.com>
	 <1210876652.17301.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Jeff Layton" <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:21533 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbYEOUAE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2008 16:00:04 -0400
Received: by wr-out-0506.google.com with SMTP id c48so299856wra.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2008 13:00:02 -0700 (PDT)
In-Reply-To: <1210876652.17301.3.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 15, 2008 at 12:37 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
>  Looks as if you've got a 32-bit application that doesn't like 64-bit
>  inode numbers. Try booting with the kernel parameter
>  'nfs.enable_ino64=0'.

Sorry if this is a dumb question, but is that going to hurt me in the
long run?  This filesystem has the capability of being rather huge
(it's currently at 27TB).

-- 
Adam Olsen
SendOutCards.com
http://www.vimtips.org
http://last.fm/user/synic
