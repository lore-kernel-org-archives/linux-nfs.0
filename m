From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Thu, 1 May 2008 09:58:54 -0400
Message-ID: <24c1515f0805010658o45e21f48g7bf35a4976b41b2f@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418203225.GD28277@fieldses.org>
	 <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
	 <20080421000214.GA5453@fieldses.org>
	 <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com>
	 <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org>
	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com>
	 <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>
	 <4819CAAB.8010200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Wendy Cheng" <wcheng@netapp.com>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "Wendy Cheng" <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:7330 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbYEAN7A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2008 09:59:00 -0400
Received: by yw-out-2324.google.com with SMTP id 5so530151ywh.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2008 06:58:55 -0700 (PDT)
In-Reply-To: <4819CAAB.8010200@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 1, 2008 at 9:50 AM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:

> > It might be even better if it would exit if -n is used when
> > no such interface is actually available. As I did it, it still
> > gambles here just as before.
> >
>  Yep, understood. Linux NFS server failover was one of my painful projects
> (actually it was "the" one - so much work and so little result).

Heh


>  But the flow you proposed confuses me. Reading the code right now (to
> refresh my memory).. Will get back to the list soon.

Patch no.1 was better imho..

To be frank, given that it has to be done this way
I would probably make it even more intrusive by
having 'clean looking' socket pool. Not that it
matters much in real life terms as there are only
two sockets, but at least it would look more
readable..


-- 
// Janne
