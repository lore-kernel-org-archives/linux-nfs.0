From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfsd closes port 2049
Date: Thu, 18 Oct 2007 07:59:25 -0400
Message-ID: <EXNANE013MBhe3WYIgo0000075b@exnane01.hq.netapp.com>
References: <47139C02.9020009@cineca.it>
	<18195.52347.544844.155538@notabene.brown>
	<4713E25D.6090302@users.sourceforge.net>
	<EXNANE014r3mbfJ8VrR0000070e@exnane01.hq.netapp.com>
	<18198.64875.25036.248314@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, righiandr@users.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiU2R-00080u-Vp
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 04:59:45 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IiU2X-0000kb-BR
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 04:59:49 -0700
In-Reply-To: <18198.64875.25036.248314@notabene.brown>
References: <47139C02.9020009@cineca.it>
	<18195.52347.544844.155538@notabene.brown>
	<4713E25D.6090302@users.sourceforge.net>
	<EXNANE014r3mbfJ8VrR0000070e@exnane01.hq.netapp.com>
	<18198.64875.25036.248314@notabene.brown>
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

At 02:30 AM 10/18/2007, Neil Brown wrote:
>On Tuesday October 16, Thomas.Talpey@netapp.com wrote:
>> BTW, the nfsd_acceptable() issue is different from this one, and the
>> no_subtree_check I suggested may still be needed (right Neil?). I'm
>> interested in what you find - keep us posted.
>
>I don't know exactly what you mean by "the nfsd_acceptable() issue",
>but whatever it is, it would be completely separate from tcp
>connections.

It was the messages in the logs Andrea sent, here's one:

>>Oct 13 05:20:56 node0101 kernel: nfsd_acceptable failed at ffff8100c7873700

>If a filesystems got unexported, or a "chmod -x" made some directories
>unaccessible, it would not close any TCP connection.  It would simply
>return an error status for every request, leaving the TCP connection
>active.

Fair enough - the clients wouldn't automatically close the connections
due to this, either. So the race condition at the server is the probable
cause of Andrea's observed error.

I still think adding no_subtree_check will help the situation. These
export failures are coming from some failed check at the server, and
they're rare enough to make me think there's a GPFS or other server
issue at work from time to time. 

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
