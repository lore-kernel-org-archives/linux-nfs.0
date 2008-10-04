From: "Roy M." <setesting001@gmail.com>
Subject: Re: Is NFS v4 stable and recommend to use now?
Date: Sat, 4 Oct 2008 21:34:49 +0800
Message-ID: <beaf78240810040634i672904c7g51e02855227a9d7c@mail.gmail.com>
References: <beaf78240810020949j703d95cvab1c44f33bff7019@mail.gmail.com>
	 <20081002171719.GA30408@fieldses.org>
	 <beaf78240810021034k3cb7db69p7ac458b8a3cfbb28@mail.gmail.com>
	 <20081003215247.GJ19057@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:62431 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbYJDNey (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Oct 2008 09:34:54 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2122374rvb.1
        for <linux-nfs@vger.kernel.org>; Sat, 04 Oct 2008 06:34:49 -0700 (PDT)
In-Reply-To: <20081003215247.GJ19057@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Sat, Oct 4, 2008 at 5:52 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> I doubt the pattern of I/O really matters much--it's the opens and
> closes themselves that matter.
>
> (In v3, close-to-open cache consistency requires that the client always
> fetch file attributes from the server on an open.  That means open() is
> always going to take at least the ping time to the server.  In v4 in
> some situations the client can do the open with no call to the server at
> all--by comparison such an open is almost instantaneous.  If you're
> doing a ton of opens all in a row, that may make a difference.)
>

In existing v3, you mean even if a file is cached locally by client,
in each open, the file attributes need to be read from NFS server
everytime?

But I just wonder without reading the NFS server, how the consistency
was maintained...


Thanks.
