From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] read-modify-write page updating
Date: Thu, 09 Jul 2009 09:59:18 -0400
Message-ID: <4A55F7B6.80800@redhat.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <49FA0CE8.9090706@redhat.com>	 <1241126587.15476.62.camel@heimdal.trondhjem.org>	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>	 <1243615595.7155.48.camel@heimdal.trondhjem.org>	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>	 <1243618500.7155.56.camel@heimdal.trondhjem.org>	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>	 <1243686363.5209.16.camel@heimdal.trondhjem.org>	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>	 <1243963631.4868.124.camel@heimdal.trondhjem.org>	 <18982.41770.293636.786518@fisica.ufpr.br>	 <1244049027.5603.5.camel@heimdal.trondhjem.org>	 <OFB53BFCCB.0CEC7A7E
 -ON852575CA.006BA196-852575CB.00613ABC@us.ibm.com>	 <1244138698.5203.59.camel@heimdal.trondhjem.org>	 <4A428482.60403@redhat.com> <1245950029.4913.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Brian R Cowan <brcowan@us.ibm.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41489 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759129AbZGIN7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jul 2009 09:59:24 -0400
In-Reply-To: <1245950029.4913.17.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
>
> It might also be nice to put the above test in a little inlined helper
> function (called nfs_want_read_modify_write() ?).
>
>   

Good suggestion.

> So, a number of questions spring to mind:
>
>      1. What if we're extending the file? We might not need to read the
>         page at all in that case (see nfs_write_end()).
>   

Yup.

>      2. What if the page is already dirty or is carrying an uncommitted
>         unstable write?
>   

Yup.

>      3. We might want to try to avoid looping more than once here. If
>         the kernel is very low on memory, we might just want to write
>         out the data rather than read the page and risk having the VM
>         eject it before we can dirty it.
>   

Yup.

>      4. Should we be starting an async readahead on the next page?
>         Single page sized reads can be a nuisance too, if you are
>         writing huge amounts of data.

This one is tough.  It sounds good, but seems difficult to implement.

I think that this could be viewed as an optimization.

       ps

