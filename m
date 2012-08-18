Return-Path: linux-nfs-owner@vger.kernel.org
Received: from isrv.corpit.ru ([86.62.121.231]:36133 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709Ab2HRM6d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Aug 2012 08:58:33 -0400
Message-ID: <502F9177.5060100@msgid.tls.msk.ru>
Date: Sat, 18 Aug 2012 16:58:31 +0400
From: Michael Tokarev <mjt@tls.msk.ru>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux-kernel <linux-kernel@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0+ NFS issues (bisected)
References: <20120817145616.GC11172@fieldses.org> <20120817160057.GE11172@fieldses.org> <502E7B86.3060702@msgid.tls.msk.ru> <20120817171854.GA14015@fieldses.org> <502E7EC3.5030006@msgid.tls.msk.ru> <502E7F84.3060003@msgid.tls.msk.ru> <20120817191800.GA14620@fieldses.org> <20120817200807.GB14620@fieldses.org> <20120817223253.GA15659@fieldses.org> <502F3AFB.4080401@msgid.tls.msk.ru> <20120818111354.GA16611@fieldses.org>
In-Reply-To: <20120818111354.GA16611@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18.08.2012 15:13, J. Bruce Fields wrote:
> On Sat, Aug 18, 2012 at 10:49:31AM +0400, Michael Tokarev wrote:
[]
>> Well.  What can I say?  With the change below applied (to 3.2 kernel
>> at least), I don't see any stalls or high CPU usage on the server
>> anymore.  It survived several multi-gigabyte transfers, for several
>> hours, without any problem.  So it is a good step forward ;)
>>
>> But the whole thing seems to be quite a bit fragile.  I tried to follow
>> the logic in there, and the thing is quite a bit, well, "twisted", and
>> somewhat difficult to follow.  So I don't know if this is the right
>> fix or not.  At least it works! :)
> 
> Suggestions welcomed.

Ok...

Meanwhile, you can add my
Tested-By: Michael Tokarev <mjt@tls.msk.ru>

to the patch.

>> And I really wonder why no one else reported this problem before.
>> Is me the only one in this world who uses linux nfsd? :)
> 
> This, for example:
> 
> 	http://marc.info/?l=linux-nfs&m=134131915612287&w=2
> 
> may well describe the same problem....  It just needed some debugging
> persistence, thanks!

Ah.  I tried to find something when I initially
sent this report, but weren't able to.  Apparently
I'm not alone with this problem indeed!

Thank you for all the work!

/mjt
