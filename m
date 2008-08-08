From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: NFS performance / diagnostic profiling with TCP
Date: Thu, 07 Aug 2008 19:16:12 -0700
Message-ID: <489BAC6C.5090801@gmail.com>
References: <f257b9ab0807151118x5dec64aei73c284c9954fcfb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: ntwrkd <ntwrkd@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:9561 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755571AbYHHCQQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2008 22:16:16 -0400
Received: by wr-out-0506.google.com with SMTP id 69so588824wri.5
        for <linux-nfs@vger.kernel.org>; Thu, 07 Aug 2008 19:16:15 -0700 (PDT)
In-Reply-To: <f257b9ab0807151118x5dec64aei73c284c9954fcfb-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



ntwrkd wrote:
> Does anyone have some methods for doing diagnostic / performance
> profiling while using NFS over TCP?
>   
Using tcpdump with tcptrace is really handy. 
You do something like:
tcpdump -s 100 -w /tmp/tcpdump.out host <hostname>
tcptrace -Sl /tmp/tcpdump.out
xplot /tmp/a2b_tsg.xpl

One very important thing to remember, if you are interested in how the 
tcp window is scaling, is to start tcpdump before you mount the server.  
The tcp window size depends on a scaling factor that it gets when the 
tcp connection is created (which is at mount time).

Dean


> Thanks in advance,
> Matthew Sacks
> matthewsacks.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   
