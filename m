From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Tue, 31 Aug 2004 16:51:39 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16692.8187.411591.69640@cse.unsw.edu.au>
References: <4124DB86.9060505@steeleye.com>
	<16677.22269.988036.787320@cse.unsw.edu.au>
	<412E1C10.5020703@steeleye.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C22Uj-0006Ua-Ea
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 23:51:53 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C22Ui-0007yb-R1
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 23:51:53 -0700
To: Paul Clements <paul.clements@steeleye.com>
In-Reply-To: message from Paul Clements on Thursday August 26
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

On Thursday August 26, paul.clements@steeleye.com wrote:
> Hi all,
> 
> I've recently coded up some modifications to nfs-utils that will
> allow the tools to be used in a High Availability NFS environment
> (i.e., capable of switching and failing over NFS exports from
> one server to another, while still preserving client connections
> and file locks). The modifications are in the form of callout
> hooks in statd and mountd. Any HA NFS implementation may take
> advantage of these hooks since the actual content of the callout
> programs will not be dictated by nfs-utils, but rather will be
> left up to the HA cluster software implementor.

I'm mostly happy with this patch.
I'd like to ask for two changes before it gets committed.

First - update the relevant man pages to explain -H and SIGUSR1
usage. 

Second, I have a pathological aversion to "system(3)" for this sort
of task.  I start worrying about stray quotes and other magic
characters.
I would much prefer something like:

  sprintf(buf, "%.8x" args3)
  switch(pid=fork()) {
	case 0: execl(ha_callout_prog,"callout",arg1,arg2,buf,NULL);
		exit(1);
	case -1: perror(PROGNAME ": fork"); break;
	default: waitpid(pid, NULL, 0);
  }

Also, I would really prefer the count was passed in decimal (%d) - it
is more traditional.  If hex is needed, the program can convert it.
(why it is hex in "rmtab" I really don't know)....
But I could probably be talked into hex if you try.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
