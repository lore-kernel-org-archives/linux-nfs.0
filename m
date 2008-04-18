From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 14:11:55 -0400
Message-ID: <24c1515f0804181111x465d7083o4b78e1ba36b51cb@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418173646.GC19038@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:28359 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759648AbYDRSL5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2008 14:11:57 -0400
Received: by wr-out-0506.google.com with SMTP id c48so461943wra.1
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2008 11:11:55 -0700 (PDT)
In-Reply-To: <20080418173646.GC19038@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2008 at 1:36 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  > Apparently lockd does not expect statd to be used with -n
>  > switch: statd is expected to bind loopback, always. Attached
>  > patches show one (IPv4 specific) way of fixing it. Comments?
>
>  Maybe statd really should always bind to the loopback interface?  Is
>  there any reason not to?

In my case I used -n to push NSM/NLM comms to
clusters specific NFS service address (that just
happens to migrate all around). -n is the only way
to do this: otherwise it will bind to INADDR_ANY
on node that has gazillion interfaces/addresses..

That, and the original reasoning for the option is
said in statd code:

        /*
         * If a local hostname is given (-n option to statd), bind to
the address
         * specified. This is required to support clients that ignore
the mon_name in
         * the statd protocol but use the source address from the
request packet.
         */


>  From a quick look at the current nfs-utils code: it looks like the -n
>  option only affects the operation of the sm-notify program that's called
>  on boot to notify peer statd's?  I'm a little confused.  (What version
>  of nfs-utils are you working from?)

Right. 1.0.8 -> 1.0.12, it's valid for all.


-- 
// Janne
