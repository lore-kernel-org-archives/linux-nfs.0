From: Andrew Morton <akpm@osdl.org>
Subject: Re: Bad  nsec conversion  in svc_udp_recvfrom()
Date: Wed, 26 Oct 2005 01:50:00 -0700
Message-ID: <20051026015000.609cd153.akpm@osdl.org>
References: <435F3FFC.6020303@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUgzS-0001DS-Cz
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 01:50:34 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1EUgzR-0000M1-6h
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 01:50:34 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <435F3FFC.6020303@RedHat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Steve Dickson <SteveD@redhat.com> wrote:
>
> In patch-2.6.14-rc5 there is the following:
> @@ -584,13 +583,16 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
>          /* possibly an icmp error */
>          dprintk("svc: recvfrom returned error %d\n", -err);
>      }
> -   if (skb->stamp.tv_sec == 0) {
> -       skb->stamp.tv_sec = xtime.tv_sec;
> -       skb->stamp.tv_usec = xtime.tv_nsec / NSEC_PER_USEC;
> +   if (skb->tstamp.off_sec == 0) {
> +       struct timeval tv;
> +
> +       tv.tv_sec = xtime.tv_sec;
> +       tv.tv_usec = xtime.tv_nsec * 1000;
> +       skb_set_timestamp(skb, &tv);
>          /* Don't enable netstamp, sunrpc doesn't
>             need that much accuracy */
>      }
> -   svsk->sk_sk->sk_stamp = skb->stamp;
> +   skb_get_timestamp(skb, &svsk->sk_sk->sk_stamp);
>      set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
> 
>      /*
> Shouldn't tv.tv_usec = xtime.tv_nsec * 1000
> be tv.tv_usec = xtime.tv_nsec / 1000 or possible
> tv.tv_usec = xtime.tv_nsec / NSEC_PER_USEC ?
> 
> The was fixed by a previous patch
> (see http://lkml.org/lkml/2005/8/1/251)
> but now it seems to be broken again...
> 

Yes, that's screwed up - well spotted.

Patrick, please be more careful about these things.

I'll fix it up.


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
