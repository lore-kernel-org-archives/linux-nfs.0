Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52120 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753316Ab2G2Rsl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Jul 2012 13:48:41 -0400
Date: Sun, 29 Jul 2012 13:48:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jim Rees <rees@umich.edu>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.gssd: don't call poll() twice a second
Message-ID: <20120729174839.GK6388@fieldses.org>
References: <20120727210247.GC6388@fieldses.org>
 <20120727230853.GA2707@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120727230853.GA2707@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 27, 2012 at 07:08:53PM -0400, Jim Rees wrote:
> J. Bruce Fields wrote:
> 
>   +	if (1 != write(pipefd[1], "!", 1))
>   +		printerr(2, "weird; maybe an interrupt?");
> 
> Use Yoda conditions must we?

Yeah, yeah.  How about:

	 static void something_changed(void)
	 {
	-	if (1 != write(pipefd[1], "!", 1))
	-		printerr(2, "weird; maybe an interrupt?");
	+	if (write(pipefd[1], "!", 1) != 1)
	+		printerr(0, "%s writing to pipe", strerror(errno));
	 }
 
?

--b.
