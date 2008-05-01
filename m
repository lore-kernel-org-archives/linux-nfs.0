From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Thu, 01 May 2008 09:50:35 -0400
Message-ID: <4819CAAB.8010200@gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>	 <480902CA.1070805@redhat.com> <48090356.9020703@redhat.com>	 <20080418203225.GD28277@fieldses.org>	 <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>	 <20080421000214.GA5453@fieldses.org>	 <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com>	 <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org>	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com> <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Wendy Cheng <wcheng@netapp.com>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757423AbYEANs3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2008 09:48:29 -0400
In-Reply-To: <24c1515f0805010628k6b57598btb27116c719b99fad-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Janne Karhunen wrote:
> Hi,
>
> So effectively, it makes me sleep better. With it:
> - I can rely on clients identifying the server correctly,
> - I'm not exposing out anything that is not needed,
> - Can tell by the address what this traffic is,
> - Can be sure that packets are sent out via right interface
>
> It might be even better if it would exit if -n is used when
> no such interface is actually available. As I did it, it still
> gambles here just as before.
>
>
>   
Yep, understood. Linux NFS server failover was one of my painful 
projects (actually it was "the" one - so much work and so little result).

But the flow you proposed confuses me. Reading the code right now (to 
refresh my memory).. Will get back to the list soon.

-- Wendy
