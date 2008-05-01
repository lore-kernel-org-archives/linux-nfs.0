From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: [NFS] How to set-up a Linux NFS server to handle	massive	number
 of requests
Date: Thu, 01 May 2008 12:47:06 -0700
Message-ID: <481A1E3A.4040503@gmail.com>
References: <47FE044A.7020008@aei.mpg.de>
	<20080411230754.GI24830@fieldses.org>	<1208234913.17169.50.camel@trinity.ogc.int>	<20080415151227.GB32218@fieldses.org>	<1208313790.3521.32.camel@trinity.ogc.int>	<20080416025848.GA27274@fieldses.org>
	<1208316166.3521.42.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net,
	Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37865 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759538AbYEATr2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2008 15:47:28 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JrekV-0005fT-TT
	for linux-nfs@vger.kernel.org; Fri, 02 May 2008 05:47:23 +1000
In-Reply-To: <1208316166.3521.42.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> If you really need to start 1300 mounts all at once then something needs
> to change. BTW even after you get past mountd, the server is going to
> get pounded with SYN and RPC_NOP. 
>   
Just to give my 2 cents after the fact,.. a new approach is definitely 
needed.  For example, a small 10 line MPI program that has a single 
client mount the server, calculate the md5sum, and distribute the result 
to the other 999 clients would be a much better approach....

Dean
> It might be interesting to look at httpd (Apache) to see what it does. I
> would think it faces similar traffic flows.
>
>   
>> --b.
>>
>> -------------------------------------------------------------------------
>> This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
>> Don't miss this year's exciting event. There's still time to save $100. 
>> Use priority code J8TL2D2. 
>> http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
>> _______________________________________________
>> Please note that nfs@lists.sourceforge.net is being discontinued.
>> Please subscribe to linux-nfs@vger.kernel.org instead.
>>     http://vger.kernel.org/vger-lists.html#linux-nfs
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>     
>
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
> Don't miss this year's exciting event. There's still time to save $100. 
> Use priority code J8TL2D2. 
> http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>     http://vger.kernel.org/vger-lists.html#linux-nfs
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

