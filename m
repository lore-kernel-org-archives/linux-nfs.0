From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs over TCP stable?
Date: Mon, 05 May 2003 07:29:23 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EB64B13.2080401@RedHat.com>
References: <3EB44527.6090005@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ce8r-0005hQ-00
	for <nfs@lists.sourceforge.net>; Mon, 05 May 2003 04:28:21 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h45BSEH08785
	for <nfs@lists.sourceforge.net>; Mon, 5 May 2003 07:28:14 -0400
To: nfs@lists.sourceforge.net
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

The client works fairly well due to the simple fact
a number of people are using it in production today.

The server seems to have issues around flow control. When
a server is unable to send back replies due to an EGAIN error,
it resets the connection; Clearly, IMHO, not the correct way
to hand this error.

It has been suggested to me, I and think I agree, that the
I/O processing of the NFS server should be broken up into
to threads. A RX and TX thread. With the idea being when the
TX thread starts to get backed up, it turns off the RX thread
(i.e. stops it from receiving) which in turn will flow-control
sending client. This should allow the TX thread to be able
to catch up...

The duel io threads might also be handy if NFSD decide
to use AIO....

SteveD.

Xose Vazquez Perez wrote:

>hi,
>
>Red Hat 9-kernel 2.4.20-9 doesn't include nfs over TCP because they
>said that "it doesn't work good enough in our testing....."
>https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=88583
>
>Are there any problems at standard kernels or only at
>mega-patched rh kernels?
>
>-thanks in advance-
>
>regards,
>  
>




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
