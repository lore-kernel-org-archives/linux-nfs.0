From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Trying to determine why my NFS connection goes away
Date: Fri, 15 Jun 2007 09:49:20 -0400
Message-ID: <1181915360.6135.7.camel@heimdal.trondhjem.org>
References: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
	<1181874951.15174.15.camel@heimdal.trondhjem.org>
	<bd9320b30706142333h539215b4jd3c062c4ed666e8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: mike <mike503@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HzCB4-000706-27
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 06:49:26 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19amZPJeyo2Qm0xYpUp2xZriXl0lkrsv+g=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HzCB6-0005ZZ-Vv
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 06:49:29 -0700
In-Reply-To: <bd9320b30706142333h539215b4jd3c062c4ed666e8f@mail.gmail.com>
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

On Thu, 2007-06-14 at 23:33 -0700, mike wrote:
> no - if you look at the mount parameters i am explicitly stating TCP.
> i have compiled kernels with TCP as well. i haven't used UDP in
> forever. also i do have NFSv4 available but have had odd issues in the
> past, i don't know how stable it is for simple mounts now (i don't
> need anything crazy, or thousands of client machines, etc)

Then why on earth are you using timeo=10? Use the default timeo=600 and
it will all work.

Using overly short timeouts on TCP is completely unnecessary: TCP
provides reliable delivery of data. Furthermore, a timeout forces the
client to keep disconnecting and reconnecting, and that is why you are
seeing those messages.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
