From: Yusuf Goolamabbas <yusufg@outblaze.com>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: Wed, 17 Sep 2003 12:14:18 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030917041418.GA8900@outblaze.com>
References: <482A3FA0050D21419C269D13989C6113127DC8@lavender-fe.eng.netapp.com> <3EC39FDF.60609@RedHat.com> <16067.42148.524146.39488@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	"Lever, Charles" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zTi7-0007lz-00
	for <nfs@lists.sourceforge.net>; Tue, 16 Sep 2003 21:14:35 -0700
Received: from corpmail.outblaze.com ([203.86.166.82])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zTi6-0001Gl-O3
	for nfs@lists.sourceforge.net; Tue, 16 Sep 2003 21:14:34 -0700
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by corpmail.outblaze.com (Postfix) with ESMTP id F1EDC37AD5
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 04:14:30 +0000 (GMT)
Received: from yusufg.portal2.com (210-177-227-130.outblaze.com [210.177.227.130])
	by corpmail.outblaze.com (Postfix) with SMTP id 175E916DD94
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 04:14:30 +0000 (GMT)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <16067.42148.524146.39488@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> >>>>> " " == Steve Dickson <SteveD@redhat.com> writes:
> 
>      > It appears the RTO code does seem to be working but when the
>      > minimums start so low (like at 4m instead 40ms) it takes some
>      > time for the timeout value to build up and with soft mounts
>      > there is no time...
> 
>      > Maybe I'm missing something... increasing the timeout value
>      > should not have any affect on performance since in a well tuned
>      > client and server these timeout will never occur since the
>      > responses from the server will be returned before the timeout
>      > expires... right? Also decreasing the number of timeouts will
>      > decrease the number of retransmits which is another good
>      > thing... True?
> 
> With a properly implemented algorithm, the number of retransmits
> should be small anyway as it is supposed to take into account the
> variance on the estimated RTO. We don't want any extra artificial
> limits if we can avoid it.
> 
> You may well be right in asserting that we're setting the initial RTO
> estimate too low, but then the answer should be to increase the value
> of the 'timeo' mount parameter as that is what defines the initial
> estimate.
> The default value of 'retrans' should also be looked at. I'm not at
> all comfortable with a default retrans value of '3' when doing soft
> mounts.
> 
> At the moment I believe that the default values for these 2 parameters
> differ in the kernel from those in the 'mount' program. IMHO, the
> mount program is overriding the kernel with too low values. It would
> be better if 'mount' did not set timeo/retrans (unless the user
> overrides) and left that to the kernel.

Trond, In your opinion. What should be the default retrans value given
your recent work in having adaptive timeouts in the NFS client ?

Regards, Yusuf



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
