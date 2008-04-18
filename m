From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 14:55:47 -0400
Message-ID: <24c1515f0804181155n6696b7fbg8fe898a2063eee7d@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418173646.GC19038@fieldses.org>
	 <24c1515f0804181111x465d7083o4b78e1ba36b51cb@mail.gmail.com>
	 <20080418182550.GC24552@fieldses.org>
	 <24c1515f0804181131i238a50a7v85ef80299ec2216f@mail.gmail.com>
	 <20080418183443.GE24552@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:2332 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757516AbYDRSzt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2008 14:55:49 -0400
Received: by wr-out-0506.google.com with SMTP id c48so484336wra.1
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2008 11:55:48 -0700 (PDT)
In-Reply-To: <20080418183443.GE24552@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 2:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  > >  Weird--I dont' see that comment.
>  >
>  > All original nfs-utils-1.0.12 tarball; indeed strange.
>
>  I was looking at recent git.  Note the most recent tarball on
>  sourceforge.net is 1.1.2, and that has the relevant changes.

So what has been done in 1.1.2 is that the
-n binding has been removed completely.
It would _probably_ work, but only if I'm lucky.

This way it will not only try to guess the interface
to be used (and may or may not get it right). That,
and it will expose NFS services on interfaces
that should not need them.

I'll rework the patch to 1.1.2 to see how well
it fits in.


-- 
// Janne
