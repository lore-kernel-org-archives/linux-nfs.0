From: Ian Kent <raven@themaw.net>
Subject: Re: How to find what to make "df -jk" hang (redhat)
Date: Sun, 23 Oct 2005 12:18:51 +0800 (WST)
Message-ID: <Pine.LNX.4.63.0510231205130.19701@donald.themaw.net>
References: <20051022155210.76957.qmail@web52402.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steve Dickson <steved@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ETXKo-0001M5-Lo
	for nfs@lists.sourceforge.net; Sat, 22 Oct 2005 21:19:50 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1ETXKl-0004ha-VB
	for nfs@lists.sourceforge.net; Sat, 22 Oct 2005 21:19:50 -0700
To: Jun Zhang <nugulus@yahoo.com>
In-Reply-To: <20051022155210.76957.qmail@web52402.mail.yahoo.com>
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

On Sat, 22 Oct 2005, Jun Zhang wrote:

> Steve,
>    The problem is that I don't what is trying to be
> mounted, from what server. All automount map listed
> directories are also accessible. As of this writing,
> three 'df -k' processes are still running, and refuse
> to be killed.

So you are using autofs.

That's a different story altogether.
If autofs is hanging on trying to mount something you should see the mount 
command it has issued in a ps listing. You might be able to see the 
mountpoint directory there.

Care to tell the version of autofs?
The kernel version?
What are your maps?

Maybe get a debug log of autofs by using the -d option added to your 
master map entries? Don't forget to ensure that syslog priority debug is 
being logged. Use man syslog.conf to check this.

You probably should be asking this on the autofs list.
http://linux.kernel.org/mailman/listinfo/autofs

Ian



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
