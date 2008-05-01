From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] How to set-up a Linux NFS server to handle massive	number
	of requests
Date: Thu, 1 May 2008 15:51:33 -0400
Message-ID: <20080501195132.GM28981@fieldses.org>
References: <47FE044A.7020008@aei.mpg.de> <20080411230754.GI24830@fieldses.org>
	<1208234913.17169.50.camel@trinity.ogc.int>
	<20080415151227.GB32218@fieldses.org>
	<1208313790.3521.32.camel@trinity.ogc.int>
	<20080416025848.GA27274@fieldses.org>
	<1208316166.3521.42.camel@trinity.ogc.int>
	<481A1E3A.4040503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: Dean Hildebrand <seattleplus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36561 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755960AbYEATv5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2008 15:51:57 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jreou-0005gl-AO
	for linux-nfs@vger.kernel.org; Fri, 02 May 2008 05:51:56 +1000
In-Reply-To: <481A1E3A.4040503@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 01, 2008 at 12:47:06PM -0700, Dean Hildebrand wrote:
>
>> If you really need to start 1300 mounts all at once then something needs
>> to change. BTW even after you get past mountd, the server is going to
>> get pounded with SYN and RPC_NOP.   
> Just to give my 2 cents after the fact,.. a new approach is definitely  
> needed.  For example, a small 10 line MPI program that has a single  
> client mount the server, calculate the md5sum, and distribute the result  
> to the other 999 clients would be a much better approach....

For that toy example, yes, but we still need to fix whatever's
preventing us from handling 1000 simultaneous mounts.

--b.

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

