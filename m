From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 3/4 Revised] NLM - kernel lockd-statd changes
Date: Tue, 10 Apr 2007 14:16:59 -0400
Message-ID: <461BD49B.7090503@redhat.com>
References: <46156FA0.4030506@redhat.com> <200704101109.44333.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbKrx-0003g5-Ub
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 11:15:06 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbKrz-0004uh-Mq
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 11:15:08 -0700
In-Reply-To: <200704101109.44333.okir@lst.de>
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

Olaf Kirch wrote:
> But - why do you need to record the address on which the request was
> received. at all? Don't you know beforehand on which IP addresses you
> will be servicing NFS requests, and which will need to be migrated?
>
>   

Sorry, somehow I missed this question ...

The intent is to avoid sending notifications to *all* clients.  The 
cluster user mode scripts will have to associate the floating IP(s) with 
fsid(s) and relies heavily on the information passed by rpc.statd's 
ha-callout program. My test ha-callout user mode program shows the 
following:

/mnt/lockd/ha-pg/hatest is invoked with 3 arguments.
    add-client
    192.168.24.146
    192.168.24.149
/mnt/lockd/ha-pg/hatest is invoked with 3 arguments.
    del-client
    192.168.24.145
    192.168.24.149

These info(s) will be used to construct the notification list when 
notification actually take places.

-- Wendy


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
