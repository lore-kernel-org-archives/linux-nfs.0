From: Michael <oldmoonster@gmail.com>
Subject: Re: can anyone explain this state?
Date: Wed, 17 Aug 2005 22:50:03 +0800
Message-ID: <43034E9B.1060900@gmail.com>
References: <bc57270905081704131c4b23d4@mail.gmail.com>	 <1124280174.23245.4.camel@lade.trondhjem.org>	 <43032CF2.3070908@redhat.com>	 <1124282392.23245.26.camel@lade.trondhjem.org> <bc57270905081706392d1706aa@mail.gmail.com> <43034C61.6010402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5PG2-0005YJ-Uq
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 07:51:10 -0700
Received: from zproxy.gmail.com ([64.233.162.204])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E5PG1-0002AF-II
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 07:51:11 -0700
Received: by zproxy.gmail.com with SMTP id 9so120963nzo
        for <nfs@lists.sourceforge.net>; Wed, 17 Aug 2005 07:50:14 -0700 (PDT)
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <43034C61.6010402@redhat.com>
Sender: nfs-admin@lists.sourceforge.net
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

Peter Staubach wrote:

> Michael wrote:
>
>>
>> Thanks for your feedback!
>>
>> Yes, I know it should be cache related, but you can see it took me
>> more than 1 minute at the first time copy 100Mfile from nfs server,
>> but suddenly the second time took 4 second.
>> How can the cache result to this? NFS client cache ability? ok, if it
>> is, that means NFS client could cache at least 90M data of 100M, then,
>> how to explain the last 2 copies?  with rsize=8k,first time copy 100M
>> file took 9 seconds, but the second time took 7 seconds, if cache work
>> as great as rsize=1k, why not the second time copy take less than 1
>> second?
>>
>
> The cache on the client can definitely account for the first two times.
>
> As for the second two, I don't know.  Was the client, network, and server
> otherwise completely quiescent?  What is the configuration of the client?
> Can it safely cache 100MB without loosing any data because older data 
> needed
> to be pushed out to make room for newer data?  I expect so, but it 
> would be
> good to check.
>
> What does the network traffic look like between the client and the server
> during these cp commands?  That might tell you more about what is 
> going on
> in your environment.
>
>    Thanx...
>
>       ps
>
Peter,

That's not occasional, I mount/umount for several times and copy several 
times but get the same result.
Anyway, the number of read operation in tcpdump should answer my 
question, I hope.

Thanks,

Michael


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
