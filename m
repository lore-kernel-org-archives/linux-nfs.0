From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 16:46:02 -0400
Message-ID: <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418173646.GC19038@fieldses.org> <480902CA.1070805@redhat.com>
	 <48090356.9020703@redhat.com> <20080418203225.GD28277@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:6175 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbYDRUqD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2008 16:46:03 -0400
Received: by wa-out-1112.google.com with SMTP id m16so1155665waf.23
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2008 13:46:02 -0700 (PDT)
In-Reply-To: <20080418203225.GD28277@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 4:32 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  > Sorry, not very clear.  Perhaps statd should bind to the loopback
>  > interface in addition to any other interfaces if it doesn't bind
>  > to INADDR_ANY.
>
>  Right, that's what would make the most sense to me.  Janne, is there any
>  reason that wouldn't solve your problem?

I didn't get the idea. So the idea is to use multiple sockets,
one bound to LOOPBACK and one to external interface?
Complicated and unclean in my opinion: one address
should suffice.


-- 
// Janne
