From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] sanitize logging subsystem #2
Date: Tue, 15 Mar 2005 16:37:36 +0200
Message-ID: <200503151637.36793.vda@ilport.com.ua>
References: <200503111518.29792.vda@ilport.com.ua> <16949.9802.377554.583900@cse.unsw.edu.au> <200503141626.58679.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBDBr-0000Ue-9Z
	for nfs@lists.sourceforge.net; Tue, 15 Mar 2005 06:38:35 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DBDBk-0007ie-SO
	for nfs@lists.sourceforge.net; Tue, 15 Mar 2005 06:38:35 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <200503141626.58679.vda@ilport.com.ua>
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

On Monday 14 March 2005 16:26, Denis Vlasenko wrote:
> > Otherwise the patch looks reasonably sane.
> > The only bit that bothers me is calling openlog in mountd where it
> > wasn't called before.
> > mountd (on debian at least) currently prefixes all log lines with
> > "rpc_mountd" as that is the program name.  With this patch they will
> > be prefixes with "mountd".
> > This is a change and people who filter their log file (like me) might
> > notice.   But it probably isn't a big concern..
> > 
> > I've committed it to CVS.
> 
> Your concern is indeed valid:
> 
>         /* Initialize logging. */
>         if (!foreground) xlog_stderr(0);
>         xlog_open("mountd");
> ...
>         if (!foreground) {
>                 int fd = sysconf (_SC_OPEN_MAX);
>                 while (--fd > 2)
>                         (void) close(fd);
>         }
> 
> This could close a fd to syslog socket!
> If it indeed happens, just move xlog_open below fd
> closing loop. However, you may opt to just omit xlog_open().
> I will test this scenario.

glibc behaviour:

openlog() (inside xlog_open()) does not open fds per se.
syslog() will create and connect fd to /dev/log on first call.
Moreover, if syslog() gets -EBADF (i.e. somebody has closed fd)
it will recreate socket and reconnect to /dev/log.

IOW: glibc is pretty resilient to us closing syslog fd.

I will add a comment on this and submit a patch
after your feedback on previous ones.

Cheers,
--
vda



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
