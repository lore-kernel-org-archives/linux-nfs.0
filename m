From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problem to recognize that the file system is full
Date: Tue, 04 Sep 2007 15:23:24 +0100
Message-ID: <1188915804.5999.7.camel@gaula.trondhjem.org>
References: <89a10cbc0709040701x4a6e0e3cna375e714a19b19e4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Guilherme Vilela <vilela.list@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISZK9-0008TC-SU
	for nfs@lists.sourceforge.net; Tue, 04 Sep 2007 07:24:13 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ISZKC-0004Lt-3O
	for nfs@lists.sourceforge.net; Tue, 04 Sep 2007 07:24:18 -0700
In-Reply-To: <89a10cbc0709040701x4a6e0e3cna375e714a19b19e4@mail.gmail.com>
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

On Tue, 2007-09-04 at 11:01 -0300, Guilherme Vilela wrote:
> Hi,
> I'm tryng to mount a nfs file system with the option async and run a
> program that writes to the file system. The problem is that the
> program keep writing even when the file system is full. It appears
> that the nfs dont see that the file system is full and keeps writing
> to the cache. This program does'nt occur when mounting with the sync
> option or with async and noac option, but the performance get very
> poor and that is important to my application. The problem doesnt occur
> too with the local file system. I'm running linux centos 5.0.
> 
> Bellow is my test program.
> Any idea how to resolve this problem?

You might try to backport this patch.

http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc4/linux-2.6.23-015-osync_on_error.dif

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
