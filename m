Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58437 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753665Ab2G2XJl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Jul 2012 19:09:41 -0400
Message-ID: <5015C2AA.9020608@RedHat.com>
Date: Sun, 29 Jul 2012 19:09:30 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.gssd: don't call poll() twice a second
References: <20120727210247.GC6388@fieldses.org> <20120727230853.GA2707@umich.edu> <20120729174839.GK6388@fieldses.org>
In-Reply-To: <20120729174839.GK6388@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/29/2012 01:48 PM, J. Bruce Fields wrote:
> On Fri, Jul 27, 2012 at 07:08:53PM -0400, Jim Rees wrote:
>> J. Bruce Fields wrote:
>>
>>   +	if (1 != write(pipefd[1], "!", 1))
>>   +		printerr(2, "weird; maybe an interrupt?");
>>
>> Use Yoda conditions must we?
> 
> Yeah, yeah.  How about:
> 
> 	 static void something_changed(void)
> 	 {
> 	-	if (1 != write(pipefd[1], "!", 1))
> 	-		printerr(2, "weird; maybe an interrupt?");
> 	+	if (write(pipefd[1], "!", 1) != 1)
> 	+		printerr(0, "%s writing to pipe", strerror(errno));
> 	 }
>  
> ?
Better... IMHO..  but what's going to mean when we see that in some log?

steved
