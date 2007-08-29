From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 04/20] svc: xpt_has_wspace
Date: Wed, 29 Aug 2007 13:52:36 -0500
Message-ID: <C2FB2AA4.3A881%tom@opengridcomputing.com>
References: <20070829173542.GD23541@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQSXR-0000DK-EZ
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 11:45:13 -0700
Received: from mail.es335.com ([67.65.19.105])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQSXV-0007dy-O3
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 11:45:18 -0700
In-Reply-To: <20070829173542.GD23541@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net




On 8/29/07 12:35 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Aug 20, 2007 at 11:23:30AM -0500, Tom Tucker wrote:
>> @@ -269,21 +253,13 @@ svc_sock_enqueue(struct svc_sock *svsk)
>> BUG_ON(svsk->sk_pool != NULL);
>> svsk->sk_pool = pool;
>>  
>> - set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>> - if (((atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg)*2
>> -      > svc_sock_wspace(svsk))
>> -     && !test_bit(SK_CLOSE, &svsk->sk_flags)
>> -     && !test_bit(SK_CONN, &svsk->sk_flags)) {
>> -  /* Don't enqueue while not enough space for reply */
>> -  dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
>> -   svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_max_mesg,
>> -   svc_sock_wspace(svsk));
>> + if (!test_bit(SK_CLOSE, &svsk->sk_flags)
>> +     && !test_bit(SK_CONN, &svsk->sk_flags)
>> +     && !svsk->sk_xprt->xpt_has_wspace(svsk)) {
>> svsk->sk_pool = NULL;
>> clear_bit(SK_BUSY, &svsk->sk_flags);
>> goto out_unlock;
>> }
>> - clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>> -
> 
> The reordering of the set_bit and the checks makes this patch
> non-trivial (unlike the previous ones).
> 
> Where possible it's helpful to split patches into those that are
> entirely "trivial"--e.g. that just move some code around--and those that
> might actually change behavior, and need a little more explanation to
> demonstrate that they're correct.  (And in this case the explanation may
> be very simple--apologies, I don't know the svcsock.c code well.)
> 

This is just bad. I'll create two has_wspace functions, keeping the setting
and clearing of NOSPACE in the same function.

I'll confirm the testing of SK_CLOSE and SK_CONN match the current code as
well.

> --b.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
