Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:50457 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752156Ab1G2Ueu convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 16:34:50 -0400
References: <20110729153207.17af3085@notabene.brown> <4E324DB4.7060600@fastmail.fm> <1311921035.7845.10.camel@edumazet-laptop> <4E3258E1.6020000@fastmail.fm> <20110729103634.GA12050@infradead.org> <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm> <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm> <20110729164836.GL23194@fieldses.org> <20110729165345.GM23194@fieldses.org>
Message-Id: <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
From: Greg Banks <gnb@fastmail.fm>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20110729165345.GM23194@fieldses.org>
Content-Type: text/plain;
	charset=utf-8;
	format=flowed;
	delsp=yes
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Sat, 30 Jul 2011 06:34:44 +1000
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Christoph Hellwig <hch@infradead.org>, NeilBrown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Sent from my iPhone

On 30/07/2011, at 2:53, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Jul 29, 2011 at 12:48:36PM -0400, bfields wrote:
>> On Fri, Jul 29, 2011 at 11:30:05PM +1000, Greg Banks wrote:
>>>
>>>
>>> Sent from my iPhone
>>>
>>> On 29/07/2011, at 22:11, Eric Dumazet <eric.dumazet@gmail.com>  
>>> wrote:
>>>
>>>> Le vendredi 29 juillet 2011 à 21:58 +1000, Greg Banks a écrit :
>>>>
>>>>>
>>>>> Sure, and a whole lot of the callsites are ("..._%d", cpu),  
>>>>> hence the
>>>>> unfortune :(
>>>>
>>>> BTW, we could name nfsd threads differently :
>>>>
>>>> Currently, they all are named : "nfsd"
>>>>
>>>> If SVC_POOL_PERCPU is selected, we could name them :
>>>> nfsd_c0 -> nfsd_cN
>>>>
>>>> If SVC_POOL_PERNODE is selected, we could name them :
>>>> nfsd_n0  -> nfsd_nN
>>>>
>>>> That would help to check with "ps aux" which cpu/nodes are under
>>>> stress.
>>>>
>>>>
>>>
>>> I like it!
>>
>> Yup, patch welcomed.--b.
>
> (Annoying fact: some initscripts stop nfsd using a rough equivalent of
> "killall nfsd".  So the name of the threads is arguably ABI.  I think
> those initscripts are nuts and deserve what they get, but that may be
> because I'm forgetting the reason they do that.)
>

We had this discussion in May-June 2008; it's because the nfsds were  
once  many many years ago userspace threads.

The "killall nfsd" semantics in those scripts are awful and lead to  
problems shutting down when there are lots of threads. It would  
probably be an improvement to provide a better shutdown mechanism and  
force distros to use it.

Or, you could preserve the effective semantics by having a single  
"nfsd" thread whose purpose is to notice that it's being signalled and  
perform a clean shutdown (perhaps blocking the thread doing the kill()  
call until the shutdown has completed).

Greg.