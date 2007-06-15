From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Trying to determine why my NFS connection goes away
Date: Thu, 14 Jun 2007 22:35:51 -0400
Message-ID: <1181874951.15174.15.camel@heimdal.trondhjem.org>
References: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: mike <mike503@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hz1fI-0007eA-Ss
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 19:35:56 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19jFQIu/XydCKvJ5Q9Dy1aGs/9F+EAhloM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hz1fK-0005eN-Mo
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 19:36:00 -0700
In-Reply-To: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
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

On Thu, 2007-06-14 at 16:25 -0700, mike wrote:
> THE ISSUE (easily repeatable by doing a bunch of file I/O on the client - using
> nhfsstone, eventually my "normal" web load hits it too)
> 
> I will dump as much information as possible... I really want to make
> sure that I have the most optimal setup.
> 
> This is the output from dmesg that concerns me:
> 
>  nfs: server raid01 not responding, still trying
>  nfs: server raid01 not responding, still trying
>  nfs: server raid01 not responding, still trying
>  nfs: server raid01 OK
>  nfs: server raid01 OK
>  nfs: server raid01 OK
>  nfs: server raid01 not responding, still trying
>  nfs: server raid01 not responding, still trying
>  nfs: server raid01 not responding, still trying
>  nfs: server raid01 OK
>  nfs: server raid01 OK

It sounds as if you are using UDP mounts in a situation where you
probably should be using TCP mounts.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
