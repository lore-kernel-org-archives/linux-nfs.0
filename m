From: "Kottaridis, Chris" <chris.kottaridis@windriver.com>
Subject: Re: Rpc.mountd growing 6 MB/day
Date: Mon, 30 Apr 2007 13:06:03 -0700
Message-ID: <37B62E0F71C9E14B9859FADB1FC3E3E133E55C@ala-mail02.corp.ad.wrs.com>
References: <46362BC8.9040305@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Gabriel Barazer" <gabriel@oxeva.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hic8O-0006Cx-HH
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 13:06:08 -0700
Received: from mail.windriver.com ([147.11.1.11] helo=mail.wrs.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hic8Q-0008WE-0O
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 13:06:11 -0700
In-Reply-To: <46362BC8.9040305@oxeva.fr>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

There's a comment in the support/rpc/svc.c file for the svc_getreq()
routine that makes the following statement:

/* ********************* SERVER INPUT STUFF ********************** */

/*
 * Get server side input from some transport.
 *
 * Statement of authentication parameters management:
 * This function owns and manages all authentication parameters,
specifically
 * the "raw" parameters (msg.rm_call.cb_cred and msg.rm_call.cb_verf)
and
 * the "cooked" credentials (rqst->rq_clntcred).
 * However, this function does not know the structure of the cokked
 * credentials, so it make the following assumptions:
 *  a) the structure is contiguous (no pointers), and
 *  b) the cred structure size does not exceed RQCRED_SIZE bytes.
 * In all events, all three parameters are freed upon exit from this
routine.
 * The storage is trivially management on the call stack in user land,
but
 * is mallocated in kernel land.
 */ 

I don't really know what's going on here, so I am not too sure about the
reference in the last two lines about memory management. This wouldn't
be some way in which the kernel is allocating space to the rpc.mountd
process, so if there's a leak it's in the kernel and not in the
rpc.mountd userland code would it ?

Thanks

Chris Kottaridis
Senior Engineer
Wind River Systems
719-522-9786


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
