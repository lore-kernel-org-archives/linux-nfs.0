From: James Pearson <james-p@moving-picture.com>
Subject: Re: interprtation of /proc/net/rpc/nfsd
Date: Fri, 08 Oct 2004 14:03:09 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4166900D.3060401@moving-picture.com>
References: <41666777.7030003@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFuP1-0008LZ-Mb
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 06:03:19 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CFuP0-0007UK-73
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 06:03:19 -0700
To: Jehan PROCACCIA <Jehan.Procaccia@int-evry.fr>
In-Reply-To: <41666777.7030003@int-evry.fr>
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
> Hello,
> 
> I am tunning my NFS configuration on a RedHat ES v3 (equivalent Fedora 
> Core 1 , kernel 2.4.X)  and by reading the docs (NFS howto perf 5.6 )  I 
> should see if I have enough NFSD daemon by looking at  
> /proc/net/rpc/nfs, especialy line "th"
> 
> $ grep th /proc/net/rpc/nfsd
> th 8 41598 20357.020 3974.540 1809.300 0.000 998.210 781.650 483.840 
> 116.640 0.000 825.230
> 
> However I cannot understand how to read that information !?
> I see that I have 8 threads (8 nfsd daemon runing) but figures after ???

See:

http://nfs.sourceforge.net/nfs-howto/performance.html#NFSD-INSTANCE

> Second question,
> 
> How on an NFS client (Here I have fedora core 2 clients) can I see how 
> is currently mounted an NFS filsystem, I want to check what are the 
> current options in use (nfs version, rsize, wsize, sync/async, hard, 
> soft etc ...). On the server I can have a look at /var/lib/nfs/xtab
> 
> $ cat /var/lib/nfs/xtab | grep arvouin
> /mci/mci        
> arvouin.int-evry.fr(rw,async,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,subtree_check,secure_locks,acl,mapping=identity,anonuid=-2,anongid=-2) 
> 
> 
> but I am often changing options on the server (for tunning purpose) , 
> and hence I want to check that my clients is mounted with the latest 
> options,  do I need to remount on the client everytime I change options 
> on the server ? (exportfs -r -v -a)  ... .checking what is the current 
> options on the client would be more clear to me .

I think you have to remount.

Have a look at /proc/mounts on the client.

James Pearson


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
