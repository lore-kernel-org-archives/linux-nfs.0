From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: [RFC] [PATCH 1/1] tcp-autotuning-on-recv-window-fix
Date: Thu, 23 Oct 2008 14:34:54 -0400
Message-ID: <4900C3CE.3030403@citi.umich.edu>
References: <48FE200A.6070805@citi.umich.edu> <20081022194605.GA4409@fieldses.org> <49009591.2000306@citi.umich.edu> <20081023175309.GE23838@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:48437 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752904AbYJWSfA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2008 14:35:00 -0400
In-Reply-To: <20081023175309.GE23838@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> On Thu, Oct 23, 2008 at 11:17:37AM -0400, Olga Kornievskaia wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> Could we get a really brief summary of the performance improvement for a
>>> high-speed network, to include in the commit message?
>>>   
>>>       
>> Here's a pick from some LAN performance #s: w/o 237479Mb/s => w/ 343669Mb/s.
>>     
>
> That's on a 1G network?  (With what ping time?)
>   
over 10Gb/s. ping 0.1ms
>> Are you asking for svc_sock_setbufsize() function in svcsock.c to be  
>> moved to svc_xprt.c? Why? It really belongs in svcsock.c with the rest  
>> of the socket management code.
>>     
>
> This fragment:
>
>   
>>>>  	lock_sock(sock->sk);
>>>>  	sock->sk->sk_sndbuf = snd * 2;
>>>>  	sock->sk->sk_rcvbuf = rcv * 2;
>>>> -	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
>>>>  	release_sock(sock->sk);
>>>>         
>
> should really be part of the core networking (not sunrpc) code.
>
> That's been a todo for a while.  It doesn't necessarily have to be done
> as a prerequisite to this patch.  But we should try to do it.
>
> --b.
>
>   
