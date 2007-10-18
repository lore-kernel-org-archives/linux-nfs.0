From: Andrea Righi <righiandr@users.sourceforge.net>
Subject: Re: nfsd closes port 2049
Date: Thu, 18 Oct 2007 14:42:35 +0200 (MEST)
Message-ID: <471754BA.7000907@users.sourceforge.net>
References: <47139C02.9020009@cineca.it>
	<18195.52347.544844.155538@notabene.brown>
	<4713E25D.6090302@users.sourceforge.net>
	<EXNANE014r3mbfJ8VrR0000070e@exnane01.hq.netapp.com>
	<18198.64875.25036.248314@notabene.brown>
	<EXNANE013MBhe3WYIgo0000075b@exnane01.hq.netapp.com>
Reply-To: righiandr@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiUi8-0003uN-Vt
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 05:42:49 -0700
Received: from as1.cineca.com ([130.186.84.251])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IiUiB-0007l6-LL
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 05:42:54 -0700
In-Reply-To: <EXNANE013MBhe3WYIgo0000075b@exnane01.hq.netapp.com>
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

Talpey, Thomas wrote:
> At 02:30 AM 10/18/2007, Neil Brown wrote:
>> On Tuesday October 16, Thomas.Talpey@netapp.com wrote:
>>> BTW, the nfsd_acceptable() issue is different from this one, and the
>>> no_subtree_check I suggested may still be needed (right Neil?). I'm
>>> interested in what you find - keep us posted.
>> I don't know exactly what you mean by "the nfsd_acceptable() issue",
>> but whatever it is, it would be completely separate from tcp
>> connections.
> 
> It was the messages in the logs Andrea sent, here's one:
> 
>>> Oct 13 05:20:56 node0101 kernel: nfsd_acceptable failed at ffff8100c7873700
> 
>> If a filesystems got unexported, or a "chmod -x" made some directories
>> unaccessible, it would not close any TCP connection.  It would simply
>> return an error status for every request, leaving the TCP connection
>> active.
> 
> Fair enough - the clients wouldn't automatically close the connections
> due to this, either. So the race condition at the server is the probable
> cause of Andrea's observed error.
> 
> I still think adding no_subtree_check will help the situation. These
> export failures are coming from some failed check at the server, and
> they're rare enough to make me think there's a GPFS or other server
> issue at work from time to time. 

The NFS server is working fine for the 2nd day using the fix (with kernel
2.6.16.53-0.8-smp), but I'm not yet using the no_subtree_check option. I tried
to stress the filesystem with multiple accesses from all the clients (256),
alterning with periods of inactivity. This was a good "pattern" to reproduce the
problem and since it didn't happen anymore I'm considering the issue resolved.

Anyway, I'm quite lucky :-) and I've another cluster with another identical NFS
server: same hardware, same distro, same number of clients, etc, so I can try
the no_subtree_check there.

-Andrea

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
