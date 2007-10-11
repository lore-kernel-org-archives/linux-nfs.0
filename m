From: Neil Brown <neilb@suse.de>
Subject: Re: Lock problem.
Date: Thu, 11 Oct 2007 20:08:54 +1000
Message-ID: <18189.63030.815930.43180@notabene.brown>
References: <470DE540.1090908@charta.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "matteo.debiaggi" <matteo.debiaggi@charta.it>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfuyU-0000Z1-Pt
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 03:09:02 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfuyY-0007LO-Hg
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 03:09:08 -0700
In-Reply-To: message from matteo.debiaggi on Thursday October 11
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

On Thursday October 11, matteo.debiaggi@charta.it wrote:
> Hi at all,
> Situation :
> 
> 
> Problem :
>  Some times, not every times ,we face a strange lock where reader waits 
> more or less for the same time( about 30sec,uhm..) lock gets acquired, 
> at the end it did it.

Weird... you would need a 'tcpdump -s0 ' trace of the lockd requests,
and maybe the nfs requests too.  My guess would be that the solaris
server isn't sending a 'GRANT' for some reason, and the Linux client
is timing out and retrying.

> 
> Here's simplyfied code:
> 
> WRITER:
> 
> for (;;) {
>   fd = open(file, O_WRONLY|O_APPEND|O_CREAT, 0666);

Suppose the reader wakes up here, opens the file, and gets the lock.

>   lockf(fd, F_LOCK, 0);

This then might not until the READER has read all of the file and
closed it.  So you could loose a line.  Best to check the link-count
on the file at this point, and retry if it is 0.

>   write(fd, line, LINE_SIZE);
>   lockf(fd, F_ULOCK, 0);
>   close(fd);
> 
>   usleep(WR_PAUSE);
> }
> 
> 
> READER:
> 
> for (;;) {
>   while(access(file, F_OK))
>     usleep(RD_PAUSE);
> 
>   fd = open(file, O_RDWR);
>   lockf(fd, F_LOCK, 0);
>   unlink(file);
>   lockf(fd, F_ULOCK, 0);
>   lockf(fd, F_LOCK, 0); /* incriminated lock !!! */

Why unlock and relock?  To try and avoid the race mentioned above?  I
doubt that would be reliable.

NeilBrown


> 
>   while (read(fd, line, LINE_SIZE) == LINE_SIZE)
>     ++line_numb;
> 
>   close(fd);
> }
> 
> 
> Any help would be appreciated.
> Thanks in advance.
> Matteo.
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
