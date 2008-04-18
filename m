From: "Aaron Wiebe" <epiphani@gmail.com>
Subject: Re: nfs: lock stuck after interrupt
Date: Fri, 18 Apr 2008 08:20:37 -0400
Message-ID: <e7ca40f70804180520v5687a7ccv44c08320c8cd0bce@mail.gmail.com>
References: <E1JmY9Y-0004e4-7R@pomaz-ex.szeredi.hu>
	 <e7ca40f70804171230l31aa6978x6ebfb41f9e4e7ba7@mail.gmail.com>
	 <E1JmoR2-0005j2-VU@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, trond.myklebust@fys.uio.no,
	eshel@almaden.ibm.com, neilb@suse.de, akpm@linux-foundation.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: "Miklos Szeredi" <miklos@szeredi.hu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:60010 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbYDRMUi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2008 08:20:38 -0400
Received: by wf-out-1314.google.com with SMTP id 28so414935wff.4
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2008 05:20:37 -0700 (PDT)
In-Reply-To: <E1JmoR2-0005j2-VU-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 7:07 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:

>  2) then I added your patch on top of that, which did change something
>    but not really for the better: now even the restarted lock request
>    doesn't succeed after the interrupt.
>
> According to my suspicion, this is an issue in the server, while both
> referenced patches touch only the client.

Note that my little patch purely resolves the situation we were seeing
on the client side.  We were using Netapps for servers.

We're actually using that small patch, against 2.6.22, in production
right now and it has still solved our issue.

-Aaron
