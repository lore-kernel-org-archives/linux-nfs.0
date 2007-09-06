From: "Guilherme Vilela" <vilela.list@gmail.com>
Subject: Re: Problem to recognize that the file system is full
Date: Thu, 6 Sep 2007 10:44:02 -0300
Message-ID: <89a10cbc0709060644k41d20b61xbbd47a0e0724ba4c@mail.gmail.com>
References: <89a10cbc0709040701x4a6e0e3cna375e714a19b19e4@mail.gmail.com>
	<1188915804.5999.7.camel@gaula.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: trond.myklebust@fys.uio.no
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITHeL-000511-3i
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 06:44:01 -0700
Received: from hu-out-0506.google.com ([72.14.214.227])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ITHeP-0001yg-Gq
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 06:44:05 -0700
Received: by hu-out-0506.google.com with SMTP id 28so48110hub
	for <nfs@lists.sourceforge.net>; Thu, 06 Sep 2007 06:44:03 -0700 (PDT)
In-Reply-To: <1188915804.5999.7.camel@gaula.trondhjem.org>
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

On 9/4/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Tue, 2007-09-04 at 11:01 -0300, Guilherme Vilela wrote:
> > Hi,
> > I'm tryng to mount a nfs file system with the option async and run a
> > program that writes to the file system. The problem is that the
> > program keep writing even when the file system is full. It appears
> > that the nfs dont see that the file system is full and keeps writing
> > to the cache. This program does'nt occur when mounting with the sync
> > option or with async and noac option, but the performance get very
> > poor and that is important to my application. The problem doesnt occur
> > too with the local file system. I'm running linux centos 5.0.
> >
> > Bellow is my test program.
> > Any idea how to resolve this problem?
>
> You might try to backport this patch.
>
> http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc4/linux-2.6.23-015-osync_on_error.dif
>
> Cheers
>   Trond
>
>
Thanks!

That works!

Guilherme

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
