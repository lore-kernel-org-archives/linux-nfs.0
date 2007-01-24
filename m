From: James Bardin <jbardin@bu.edu>
Subject: Re: nfs sec=krb5 on RHEL and CentOS
Date: Wed, 24 Jan 2007 15:58:04 -0500
Message-ID: <45B7C85C.80105@bu.edu>
References: <a3b675320701211411r45d010f8jd7132deedcf68804@mail.gmail.com>
	<45B73D93.1020508@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9pC3-0002oA-CR
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:58:07 -0800
Received: from wx-out-0506.google.com ([66.249.82.233])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H9pC3-00042p-2I
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 12:58:09 -0800
Received: by wx-out-0506.google.com with SMTP id i30so474884wxd
	for <nfs@lists.sourceforge.net>; Wed, 24 Jan 2007 12:58:06 -0800 (PST)
In-Reply-To: <45B73D93.1020508@RedHat.com>
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

Sorry Steve,

I accidentally rebooted into kernel 2.6.19 when I tested the patches.
Same problem still, and on our 64bit systems, everything fails with 
statfs error 13.

Here's the dmesg errors:
call_verify: auth check failed
call_verify: auth check failed
call_verify: auth check failed
RPC call_verify: retry failed, exit EIO

and:
nfs_statfs: statfs error = 13

Attached is the trace

the commands were:
$ mkdir newdir
$ ls
$ cd newdir
$ echo TESTSTRING > newfile
$ ls

thanks
-jim


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
