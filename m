From: James Pearson <james-p@moving-picture.com>
Subject: Re: interprtation of /proc/net/rpc/nfsd
Date: Fri, 08 Oct 2004 15:43:47 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4166A7A3.4020705@moving-picture.com>
References: <41666777.7030003@int-evry.fr> <4166900D.3060401@moving-picture.com> <416695F6.8080707@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFvyL-0002Oe-5x
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 07:43:53 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CFvyG-0004YV-Q3
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 07:43:53 -0700
To: Jehan PROCACCIA <Jehan.Procaccia@int-evry.fr>
In-Reply-To: <416695F6.8080707@int-evry.fr>
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
> Yes, I've read that part , but I cannot understand it :-(
> The last ten numbers on the *th* line in that file indicate the number 
> of seconds that the thread usage was at that percentage of the maximum 
> allowable.
> 
> $ grep th /proc/net/rpc/nfsd
> th 8 41598 20357.020 3974.540 1809.300 0.000 998.210 781.650 483.840 
> 116.640 0.000 825.230
> 
> Why ten numbers, I have 8 thraeds ! ? here for the last number for 
> exemple, I had 825seconds that thread number 8 was at 230% of it's 
> maximum ???

The following post from Neil Brown has a 'better' explanation:

http://marc.theaimsgroup.com/?l=linux-nfs&m=102824853219024&w=2

James Pearson


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
