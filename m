From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: lockd and statd
Date: Wed, 04 Apr 2007 19:00:47 -0400
Message-ID: <46142E1F.8050000@redhat.com>
References: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>	
	<1175690426.6118.6.camel@heimdal.trondhjem.org>	
	<57bc13580704040909o386259f1q84367459ce555671@mail.gmail.com>	
	<200704041933.27315.okir@lst.de> <4613F34C.2040709@redhat.com>
	<1175722463.7279.16.camel@heimdal.trondhjem.org>
	<46142B4F.1030507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZEnD-00069u-Au
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 16:21:31 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HZEnF-0008LP-Fk
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 16:21:33 -0700
In-Reply-To: <46142B4F.1030507@redhat.com>
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

In case there are other changes that I'm not aware of. The kernel patch 
is based on 2.6.21-rc4 kernel ... Wendy

> Trond Myklebust wrote:
>> On Wed, 2007-04-04 at 14:49 -0400, Wendy Cheng wrote:
>>  
>>>       I'm wondering what would be the reason(s) that the community 
>>> version of Linux statd is put in user space ? Any one cares to give 
>>> either a technical or historical explanation ?
>>>     
>>
>> Off the cuff, I can think of 2 main reasons why it needs to be in user
>> space:
>>  1) It creates and maintains a directory hierarchy on permanent storage
>> (as opposed to in a pseudo filesystem).
>>  2) It needs to resolve addresses via DNS etc.
>>   
>
> Ha! #2 happens to be my question.. Is there any reason why it has to 
> be dnsname ? The following is my issue:
>
> While testing out the NLM failover patches, on Neil's new 
> nfs-utils-1.1.0-rc1, sm_mon_1_svc() writes to /var/lib/nfs/sm using 
> dnsname (say, for example, dhcp146.something.com), even the kernel has 
> passed it a dotted IP address (say 192.168.24.146, since I can't use 
> "nsm_use_hostnames" as lockd module param). Unfortunately, the 
> sm_unmon_1_svc() doesn't do similar conversion. So when kernel side 
> tries to delete the monitored name, I got:
>
> Apr  4 18:12:25 dhcp143 kernel: lockd: delete host 
> dhcp146.perf.redhat.com
> Apr  4 18:12:25 dhcp143 kernel: lockd: 
> nsm_unmonitor(dhcp146.perf.redhat.com)
> Apr  4 18:12:25 dhcp143 rpc.statd[4210]: unlink 
> (/var/lib/nfs/sm/192.168.24.146): No such file or directory
>
> BTW, don't be fooled by above lockd trace (it printed out hostname but 
> I'm very sure I passed in IPV4 dotted address as seen by the attached 
> kernel statd patch).
>
> Oversight ? My configuration problem ? nfs-util bug ? my bug ? or I 
> mis-understand the logic ?
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
