From: Mario Storti <mstorti@intec.unl.edu.ar>
Subject: Re: NFS synchronization problems on Beowulf cluster
Date: 20 Jul 2006 07:49:53 -0300
Message-ID: <m1y7uopn3i.fsf@minerva.ceride.gov.ar>
References: <m1hd1gksev.fsf@minerva.ceride.gov.ar>
	<1153162159.13961.3.camel@localhost>
	<m1ejwjtb2t.fsf@minerva.ceride.gov.ar>
	<1153230531.22180.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3W8b-0004Vw-A6
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 03:52:13 -0700
Received: from [200.9.237.134] (helo=intec.unl.edu.ar)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1G3W8b-0005m1-62
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 03:52:13 -0700
Received: from minerva.ceride.gov.ar.ceride.gov.ar (localhost [127.0.0.1])
	by intec.unl.edu.ar (8.12.8/8.12.8) with ESMTP id k6KBMum6016510
	for <nfs@lists.sourceforge.net>; Thu, 20 Jul 2006 08:22:57 -0300
To: nfs@lists.sourceforge.net
In-Reply-To: <1153230531.22180.7.camel@localhost>
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


>>>>> On Tue, 18 Jul 2006 09:48:51 -0400, 
>>>>>      Trond Myklebust <trond.myklebust@fys.uio.no> said:

> On Tue, 2006-07-18 at 08:19 -0300, Mario Storti wrote:
>> > This is a FAQ that has been well-publicised and discussed to death on
>> > this list:
>> >   http://nfs.sourceforge.net/#faq_a8
>> 
>> I tried to mount with `nocto' and `noac' options without success. Also
>> tried acregmax=0,acdirmax=0. We are trying to determine if there is
>> some mistake in our configuration or if this is a `normal'
>> behavior. Your post seems to suggest that this is a `normal' behavior.
>> However, previously we had a cluster with RedHat 7.1 (kernel
>> 2.2.16-22, NFS version 2) and we didn't had problems like this.  We
>> tried to use NFS version 2 on the new cluster and the problem
>> persists. So I think that this is problem with the configuration and we
>> are still trying to solve the problem tuning the mount/server options.

> Please reread the article. This is _normal_ behaviour. NFS has never
> been guaranteed to be cache coherent in this way.

> NFS checks its data cache on calls to open()/opendir(), and on taking a
> lock. That is all.

I tried to do a `ls -l' of the directory and the contents of the files
are still out of sync. (I assume that `ls -l' does an `opendir()' call.)

Perhaps these questions are too basic for this list. In that case,
please redirect me to the appropriated list or newsgroup. 

Thanks again, Mario


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
