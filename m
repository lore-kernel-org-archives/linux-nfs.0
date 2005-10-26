From: Steve Dickson <SteveD@redhat.com>
Subject: Bad  nsec conversion  in svc_udp_recvfrom()
Date: Wed, 26 Oct 2005 04:36:12 -0400
Message-ID: <435F3FFC.6020303@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUgli-0000fB-0N
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 01:36:22 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EUglg-0007bl-Nf
	for nfs@lists.sourceforge.net; Wed, 26 Oct 2005 01:36:22 -0700
To: nfs@lists.sourceforge.net
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

In patch-2.6.14-rc5 there is the following:
@@ -584,13 +583,16 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
         /* possibly an icmp error */
         dprintk("svc: recvfrom returned error %d\n", -err);
     }
-   if (skb->stamp.tv_sec == 0) {
-       skb->stamp.tv_sec = xtime.tv_sec;
-       skb->stamp.tv_usec = xtime.tv_nsec / NSEC_PER_USEC;
+   if (skb->tstamp.off_sec == 0) {
+       struct timeval tv;
+
+       tv.tv_sec = xtime.tv_sec;
+       tv.tv_usec = xtime.tv_nsec * 1000;
+       skb_set_timestamp(skb, &tv);
         /* Don't enable netstamp, sunrpc doesn't
            need that much accuracy */
     }
-   svsk->sk_sk->sk_stamp = skb->stamp;
+   skb_get_timestamp(skb, &svsk->sk_sk->sk_stamp);
     set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */

     /*
Shouldn't tv.tv_usec = xtime.tv_nsec * 1000
be tv.tv_usec = xtime.tv_nsec / 1000 or possible
tv.tv_usec = xtime.tv_nsec / NSEC_PER_USEC ?

The was fixed by a previous patch
(see http://lkml.org/lkml/2005/8/1/251)
but now it seems to be broken again...

steved.




-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
