From: Steve Dickson <SteveD@redhat.com>
Subject: Re: interprtation of /proc/net/rpc/nfsd
Date: Mon, 11 Oct 2004 07:13:42 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <416A6AE6.8060309@RedHat.com>
References: <41666777.7030003@int-evry.fr> <4166900D.3060401@moving-picture.com> <416695F6.8080707@int-evry.fr> <4166A7A3.4020705@moving-picture.com> <4166B647.2010506@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: James Pearson <james-p@moving-picture.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CGy81-0005aR-AG
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 04:14:09 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CGy80-0001K0-C2
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 04:14:09 -0700
To: Jehan PROCACCIA <Jehan.Procaccia@int-evry.fr>
In-Reply-To: <4166B647.2010506@int-evry.fr>
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

Jehan PROCACCIA wrote:

> however how can I zero these counters ?, restarting /etc/init.d/nfs 
> doesn't do it, neither :
> $ nfsstat -z
> nfsstat: zeroing of nfs server statistics is not supported
> nfsstat: zeroing of nfs client statistics is not supported
>
Well... zeroing out the nfs stats was something I proposed a while ago
but got shoot down both internally and externally since zero out stats
is "not the Linux way".... so I've taken the patch out of both FC and RHEL
kernels, but I guess I forgot to take it out of the nfs-utils....

I could probably dig up the patch if your interested.....

> Is the only solution is to rebbot :-( ?

No. "rmmod nfs && modprobe nfs" also does the trick....

SteveD.


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
