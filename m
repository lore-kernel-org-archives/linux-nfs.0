From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: invalid argument when creating a file on an nfs share
Date: Tue, 23 Oct 2007 17:05:45 -0400
Message-ID: <1193173545.20475.50.camel@heimdal.trondhjem.org>
References: <ffkhif$h1c$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeroen <jwilke@baselogistics.nl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkQvu-0007VN-Jr
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 14:05:02 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IkQvy-0000Fh-Oc
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 14:05:08 -0700
In-Reply-To: <ffkhif$h1c$1@ger.gmane.org>
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


On Tue, 2007-10-23 at 12:17 +0200, Jeroen wrote:
> Hi all,
> 
> Whenever I try saving a file to a mounted nfs share I get the following 
> error :
> 
> /mnt/home/user$ touch bla
> touch: setting times of `bla': Invalid argument
> 
> it does create the file bla in the specified location but I am unsure as 
> to what is causing this error.

"strace -v -o dump touch bla" should tell you which command is failing,
and the exact error being returned.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
