From: "Aaron Wiebe" <epiphani@gmail.com>
Subject: Re: Client performance questions
Date: Tue, 11 Dec 2007 12:11:54 -0500
Message-ID: <e7ca40f70712110911w5c4ee95dpf13bb4914e9a8536@mail.gmail.com>
References: <0a15723c4b267d4eb8b5ad05800315c0@swip.net>
	 <e7ca40f70712110737x698b35a8g32377485cc7d8a16@mail.gmail.com>
	 <20732321-A9D9-4A20-8337-C8CBEC988A57@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Fredrik Lindgren" <fli-FpffG6+3qsA@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.237]:3105 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbXLKRL4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 12:11:56 -0500
Received: by nz-out-0506.google.com with SMTP id s18so1231022nze
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2007 09:11:55 -0800 (PST)
In-Reply-To: <20732321-A9D9-4A20-8337-C8CBEC988A57@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Afternoon..

On Dec 11, 2007 12:03 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> If windowing is a problem, have you tried boosting the default size
> of the socket send and receive buffers on both ends?

I believe we tweaked that on the client side at one point, but our
issues with the current settings puts most of the problems on the
storage side at present.  We've shifted our concentration mostly
towards getting our storage itself performing better, rather than
getting client throughput higher so we can crush our storage even
more.  But since these things tend to be cyclical, I'll keep it in
mind for when our bottleneck shifts back again. :)

-Aaron
