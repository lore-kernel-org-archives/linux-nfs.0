From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS Server lockup
Date: Sat, 29 Jun 2002 01:12:04 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15644.31940.697355.594728@notabene.cse.unsw.edu.au>
References: <200206290018.39994.chrisjensen@chrisjensen.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17NyGm-00025A-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Jun 2002 09:06:48 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <chrisjensen@chrisjensen.info>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Sat, 29 Jun 2002 02:06:38 +1000
To: chrisjensen@chrisjensen.info
In-Reply-To: message from Chris Jensen on Saturday June 29
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Saturday June 29, chrisjensen@chrisjensen.info wrote:
> Hi,
> I recently experienced a lock up from the nfs software on my linux box.
> I had a partition (type vfat), shared read only from one computer and another 
> computer I was untaring an archive stored on that partition to a local disk - 
> the untarring process stopped in the middle of extracting.
> Here's what ps -x had to say about the nfs processes:
>   118 ?        DW     0:00 [nfsd]
>   119 ?        DW     0:00 [nfsd]
>   120 ?        SW     0:00 [lockd]
>   121 ?        SW     0:02 [rpciod]
>   122 ?        DW     0:00 [nfsd]
>   124 ?        DW     0:00 [nfsd]
>   125 ?        DW     0:00 [nfsd]
>   126 ?        DW     0:00 [nfsd]
>   127 ?        DW     0:00 [nfsd]
> 
> Attatched is a portion of the servers sys.log when it occured.
> 
> I tried restarting all NFS processes - but stopping nfsd failed.
> 
> The only solution I could find was to reboot the server
> After I rebooted, I remounted the share on the client computer and tried 
> extracting the tar archive again - it went fine that time.
> 
> Does anyone know what may have caused this?
> I'm running kernel 2.4.17 with preempt and lock breaking patches, and 
> nfs-utils-0.3.1

Known bug in 2.4.17.  Fixed in 2.4.18.
Are you exporting your FAT filesystem with no_subtree_check??  It will
be more reliable and (I think) not so susceptible to this bug.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Caffeinated soap. No kidding.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
