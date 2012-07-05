Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56365 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784Ab2GETAI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jul 2012 15:00:08 -0400
Received: by eeit10 with SMTP id t10so3361445eei.19
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jul 2012 12:00:07 -0700 (PDT)
Date: Thu, 5 Jul 2012 20:59:56 +0200 (CEST)
From: Eldad Zack <eldad@fogrefinery.com>
To: Joe Perches <joe@perches.com>
cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] sunrpc/cache.h: replace simple_strtoul
In-Reply-To: <1341444227.2058.5.camel@joe2Laptop>
Message-ID: <alpine.DEB.2.02.1207052039080.6660@debianer>
References: <1341442827-21339-1-git-send-email-eldad@fogrefinery.com>  <1341442827-21339-2-git-send-email-eldad@fogrefinery.com> <1341444227.2058.5.camel@joe2Laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 4 Jul 2012, Joe Perches wrote:
> On Thu, 2012-07-05 at 01:00 +0200, Eldad Zack wrote:
> > This patch replaces the usage of simple_strtoul with kstrtoint in
> > get_int().
> 
> >  	int len = qword_get(bpp, buf, 50);
> This would be nicer as
> 	int len = qword_get(bpp, buf, sizeof(buf));

I agree, thanks!

> > @@ -226,8 +226,8 @@ static inline int get_int(char **bpp, int *anint)
> > +	ret = kstrtoint(buf, 0, &rv);
> > +	if (ret)
> >  		return -EINVAL;
> >  
> >  	*anint = rv;
> ret and rv aren't useful anymore.
> 
> Perhaps:
> 
> 	if (kstrtoint(buf, 0, anint))
> 		return -EINVAL;
> 
> 	return 0;

Yes, that works better, since kstrtoint() will not write to anint 
unless it's successful, so the whole business with rv is 
indeed redundant.

Looks much neater now thanks to your comments - I will resend it 
a bit later. Should I add you as Signed-off-by?

Eldad
