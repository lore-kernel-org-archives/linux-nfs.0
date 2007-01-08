From: "Chakri n" <chakriin5@gmail.com>
Subject: NFS and 'intr' mount option problems in 2.4 kernel
Date: Mon, 8 Jan 2007 10:42:33 -0800
Message-ID: <92cbf19b0701081042l145e54cx8053d50a2b5871e2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H3zS6-0000Qb-WB
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 10:42:35 -0800
Received: from wr-out-0506.google.com ([64.233.184.236])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H3zS7-0002LW-Gz
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 10:42:36 -0800
Received: by wr-out-0506.google.com with SMTP id i21so2762517wra
	for <nfs@lists.sourceforge.net>; Mon, 08 Jan 2007 10:42:34 -0800 (PST)
To: nfs@lists.sourceforge.net
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

Hi,

I am having a problem interrupting any calls/commands waiting on a NFS share.
I used the "intr" mount option to mount the NFS share and the NFS
server went offline after some time. Now all the commands or calls
invoked on this share get hung.

The reason seems to be due to "__wait_event" in NFS sunrpc module.
Even though one of the tasks gets woken up regularly after timeout and
checks for any pending signals, most of the commands continue to wait
on "__wait_event" in "pending_queue" and never get a chance to run.
So, they never come out even though they are killed by -9. The only
option available now is to kill all the processes waiting on the
share.

Was there any specific reason to, why we need to wait using
"__wait_event" rather than "wait_event_interruptible"? or
adding "timer" to tasks waiting on "pending_queue" to make sure they
come out of "__wait_event" after some time out and check for any
pending signals?

I think most of these problems have been addressed in 2.6, but if we
want to fix some of the issues in 2.4 for those like me who are still
using 2.4, are there any side effects using "wait_event_interruptible"
in place of "__wait_event" or adding "timer" to tasks waiting on
"pending_queue"?

Thanks
--Chakri

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
