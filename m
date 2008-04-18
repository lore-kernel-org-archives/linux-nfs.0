From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 14:31:40 -0400
Message-ID: <24c1515f0804181131i238a50a7v85ef80299ec2216f@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418173646.GC19038@fieldses.org>
	 <24c1515f0804181111x465d7083o4b78e1ba36b51cb@mail.gmail.com>
	 <20080418182550.GC24552@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:5007 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760456AbYDRSbk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2008 14:31:40 -0400
Received: by wa-out-1112.google.com with SMTP id m16so1076499waf.23
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2008 11:31:40 -0700 (PDT)
In-Reply-To: <20080418182550.GC24552@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 2:25 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  >         /*
>  >          * If a local hostname is given (-n option to statd), bind to
>  > the address
>  >          * specified. This is required to support clients that ignore
>  > the mon_name in
>  >          * the statd protocol but use the source address from the
>  > request packet.
>  >          */
>
>  Weird--I dont' see that comment.

All original nfs-utils-1.0.12 tarball; indeed strange.

But to be honest, I don't instantly understand how
this would work without -n at all (apart blind luck).
INADDR_ANY has no guarantees..


-- 
// Janne
