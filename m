From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: Re: NFS performance / diagnostic profiling with TCP
Date: Wed, 16 Jul 2008 10:29:36 +1000
Message-ID: <487D40F0.7010303@cse.unsw.edu.au>
References: <f257b9ab0807151118x5dec64aei73c284c9954fcfb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: ntwrkd <ntwrkd@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tone.orchestra.cse.unsw.EDU.AU ([129.94.242.59]:37652 "EHLO
	tone.orchestra.cse.unsw.EDU.AU" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753943AbYGPAoF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2008 20:44:05 -0400
In-Reply-To: <f257b9ab0807151118x5dec64aei73c284c9954fcfb-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

You could use a tool like iozone, bonnie or nfsreplay to
generate a workload against the server and collect profiling samples
using oprofile. I ran a bunch of tests some time back using nfsreplay,
see the results on the page below as a sample of the kind of data you
could generate using oprofile:

http://www.gelato.unsw.edu.au/IA64wiki/NFSServerPerformance#head-b5a633e0fccdde424b0395181f90efa08d56d048


Shehjar

ntwrkd wrote:
> Does anyone have some methods for doing diagnostic / performance 
> profiling while using NFS over TCP?
> 
> Thanks in advance, Matthew Sacks matthewsacks.com -- To unsubscribe
>  from this list: send the line "unsubscribe linux-nfs" in the body 
> of a message to majordomo@vger.kernel.org More majordomo info at 
> http://vger.kernel.org/majordomo-info.html

