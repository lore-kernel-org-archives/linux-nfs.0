From: Jehan PROCACCIA <Jehan.Procaccia@int-evry.fr>
Subject: Re: interprtation of /proc/net/rpc/nfsd
Date: Mon, 11 Oct 2004 15:01:30 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <416A842A.7060308@int-evry.fr>
References: <41666777.7030003@int-evry.fr> <4166900D.3060401@moving-picture.com> <416695F6.8080707@int-evry.fr> <4166A7A3.4020705@moving-picture.com> <4166B647.2010506@int-evry.fr> <416A6AE6.8060309@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: James Pearson <james-p@moving-picture.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CGzoE-0005Xj-2c
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 06:01:50 -0700
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CGzoC-0006JI-Kx
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 06:01:49 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <416A6AE6.8060309@RedHat.com>
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

Steve Dickson wrote:

> Jehan PROCACCIA wrote:
>
>> however how can I zero these counters ?, restarting /etc/init.d/nfs 
>> doesn't do it, neither :
>> $ nfsstat -z
>> nfsstat: zeroing of nfs server statistics is not supported
>> nfsstat: zeroing of nfs client statistics is not supported
>>
> Well... zeroing out the nfs stats was something I proposed a while ago
> but got shoot down both internally and externally since zero out stats
> is "not the Linux way".... so I've taken the patch out of both FC and 
> RHEL
> kernels, but I guess I forgot to take it out of the nfs-utils....
>
> I could probably dig up the patch if your interested.....

I was, but if it's not recommended ...., however your solution below 
(/etc/init.d/nfs stop; modprobe -r nfsd; /etc/init.d/nfs start) does 
perfecly the job of zeroing stats :-)

Thanks .

>
>> Is the only solution is to rebbot :-( ?
>
>
> No. "rmmod nfs && modprobe nfs" also does the trick....
>
> SteveD.




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
