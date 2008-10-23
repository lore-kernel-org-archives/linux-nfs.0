From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] [PATCH 1/1] tcp-autotuning-on-recv-window-fix
Date: Thu, 23 Oct 2008 13:53:09 -0400
Message-ID: <20081023175309.GE23838@fieldses.org>
References: <48FE200A.6070805@citi.umich.edu> <20081022194605.GA4409@fieldses.org> <49009591.2000306@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48765 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752590AbYJWRxL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2008 13:53:11 -0400
In-Reply-To: <49009591.2000306@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 23, 2008 at 11:17:37AM -0400, Olga Kornievskaia wrote:
> J. Bruce Fields wrote:
>> Could we get a really brief summary of the performance improvement for a
>> high-speed network, to include in the commit message?
>>   
> Here's a pick from some LAN performance #s: w/o 237479Mb/s => w/ 343669Mb/s.

That's on a 1G network?  (With what ping time?)

> Are you asking for svc_sock_setbufsize() function in svcsock.c to be  
> moved to svc_xprt.c? Why? It really belongs in svcsock.c with the rest  
> of the socket management code.

This fragment:

>>>  	lock_sock(sock->sk);
>>>  	sock->sk->sk_sndbuf = snd * 2;
>>>  	sock->sk->sk_rcvbuf = rcv * 2;
>>> -	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
>>>  	release_sock(sock->sk);

should really be part of the core networking (not sunrpc) code.

That's been a todo for a while.  It doesn't necessarily have to be done
as a prerequisite to this patch.  But we should try to do it.

--b.
