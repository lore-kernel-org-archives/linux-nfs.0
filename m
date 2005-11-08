From: Steve Dickson <SteveD@redhat.com>
Subject: Re: oops in rpc_pipe_release
Date: Tue, 08 Nov 2005 15:51:33 -0500
Message-ID: <43710FD5.8080306@RedHat.com>
References: <436FEB9B.3010007@google.com> <4370B4E0.6090306@RedHat.com>	 <4370F072.3090104@google.com>  <4370F56D.6090606@RedHat.com> <1131479893.32482.45.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZaRa-0007Az-Gm
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 12:51:50 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EZaRZ-0000gu-7X
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 12:51:50 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1131479893.32482.45.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> 
> I'd rather like to find out how this is happening, and fix the root
> cause. Your patch seems like a bit too much of a band-aid.
Yeah I know its a hack.... I just wanted to make sure it address
the root cause of Vince's problem... Unfortunately I'm a bit
under the gun w.r.t, to deadlines... and an oops is an oops...
so I might have to go with it...

> 
> My point is that we should never want to find ourselves in the situation
> that the directory is being cleared without the auth code having first
> cleaned up and deleted its pipes.
Well here is how you should be able to reproduce it
as spelled out in bz 171112:
(https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=171112)

root# mount -o krb5 server:/export /mnt
user$ cd /mnt
root# /bin/service nets stop
root# /bin/service rpcidmapd stop
root# kill -9 $(pgrep -u <user>)


steved.



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
