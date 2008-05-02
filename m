From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 2 May 2008 17:15:43 -0400
Message-ID: <24c1515f0805021415t65b39300s5f96c2b29a2723d3@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
	 <20080421000214.GA5453@fieldses.org>
	 <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com>
	 <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org>
	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com>
	 <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>
	 <481B316E.8090800@gmail.com>
	 <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "Wendy Cheng" <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:11706 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934810AbYEBVPn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 17:15:43 -0400
Received: by wa-out-1112.google.com with SMTP id j37so512909waf.23
        for <linux-nfs@vger.kernel.org>; Fri, 02 May 2008 14:15:43 -0700 (PDT)
In-Reply-To: <24c1515f0805021413u450d8bbcr806a90c327b287a1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 2, 2008 at 5:13 PM, Janne Karhunen <janne.karhunen@gmail.com> wrote:

>  >  After browsing thru "statd -n" flow, it is still not clear what will happen
>  > if there are more than 2 interfaces used to export NFS shares ?
>
>  How come? It will use the interface specified with -n.

Ah, you were talking about rest of the services. Yeah,
we would need to go this through one patch at a time.


-- 
// Janne
