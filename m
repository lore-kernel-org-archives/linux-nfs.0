From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: question on sk_sem within svc_sendto
Date: 30 Apr 2003 17:30:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsllxsngts.fsf@charged.uio.no>
References: <E199G1Z-0004eg-00@sc8-sf-list2.sourceforge.net>
	<BAY2-DAV28rRZ1UbDBR000085f3@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AtXR-0005DF-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 08:30:30 -0700
To: "Wendy Cheng" <s_wendy_cheng@hotmail.com>
In-Reply-To: <BAY2-DAV28rRZ1UbDBR000085f3@hotmail.com>
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

>>>>> " " == Wendy Cheng <s_wendy_cheng@hotmail.com> writes:

     > We're in the middle of fine-tuning our linux-based file server
     > and currently examining the NFS zero-copy path with 2.5.x
     > kernel. There is a semaphore (sk_sem) within svc_sendto() that
     > serializes the outgoing data. Could someone shed some light and
     > give us an explanation why this semaphore is needed - just for
     > education purpose.Great thanks...

You need to send one datagram at a time down each socket otherwise the
client might receive data which is partially from one request,
partially from another.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
