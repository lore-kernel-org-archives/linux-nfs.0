From: "Roy M." <setesting001@gmail.com>
Subject: Re: Is NFS v4 stable and recommend to use now?
Date: Fri, 3 Oct 2008 01:34:51 +0800
Message-ID: <beaf78240810021034k3cb7db69p7ac458b8a3cfbb28@mail.gmail.com>
References: <beaf78240810020949j703d95cvab1c44f33bff7019@mail.gmail.com>
	 <20081002171719.GA30408@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:11970 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502AbYJBRew (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Oct 2008 13:34:52 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1206944wfd.4
        for <linux-nfs@vger.kernel.org>; Thu, 02 Oct 2008 10:34:51 -0700 (PDT)
In-Reply-To: <20081002171719.GA30408@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Fri, Oct 3, 2008 at 1:17 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Oct 03, 2008 at 12:49:50AM +0800, Roy M. wrote:
>
> If you're just doing big I/O to a few files, that may be all you care
> about.  If you're doing something more complicated then the situation
> isn't well understood yet.
>

Do you mean for few files with large size stored in NFS, then maybe
not benefit too much from NFS4, while if I have many files, need to
fetch to client in parallel and in high concurrency, then it might be
a good choice? (in fact, I also heard client side caching in v4 is
better)


Besides, can I say v4 is the recommended to be used in production right now?

Thanks.
