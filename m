From: "S. Wendy Cheng" <wcheng@redhat.com>
Subject: Re: [PATCH 1/4 Revised] NLM - drop per fsid locks
Date: Mon, 09 Apr 2007 18:56:52 -0400
Message-ID: <461AC4B4.7060504@redhat.com>
References: <46156F60.1040400@redhat.com>
	<20070409184902.GA30444@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hb2lR-0007Lu-DY
	for nfs@lists.sourceforge.net; Mon, 09 Apr 2007 15:55:09 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hb2lT-0000bF-Li
	for nfs@lists.sourceforge.net; Mon, 09 Apr 2007 15:55:12 -0700
In-Reply-To: <20070409184902.GA30444@infradead.org>
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

Christoph Hellwig wrote:
> On Thu, Apr 05, 2007 at 05:51:28PM -0400, Wendy Cheng wrote:
>   
>> By writing exported filesytem id into /proc/fs/nfsd/nlm_unlock, this 
>> patch walks thru lockd's global nlm_files list to release all the locks 
>> associated with the particular id. It is used to enable NFS lock 
>> failover with active-active clustered servers.
>>
>> Relevant steps:
>> 1) Exports filesystem with "fsid" option as:
>>  /etc/exports entry> /mnt/shared/exports *(fsid=1234,sync,rw)
>> 2) Drops locks based on fsid by:
>>  shell> echo 1234 > /proc/fs/nfsd/nlm_unlock
>>     
>
> This is a very awkward API.  Dropping locks should support uuid or
> dev_t based exports aswell.  Also it would be nice if you we had
> a more general push api for changes to filesystem state, that works
> on a similar basis as getting information from /etc/exports.
>   
These can be added as future enhancements. But be aware that:
1. The "dev_t" value may be an obvious thing for a kernel developer but 
not necessarily for admin(s) (human operator) or cluster script (that 
has to use extra steps to obtain it).
2. Device major and minor numbers can change between different servers 
(shared storage case) or between reboots. The "fsid" approach should be 
encouraged.
3. UUID is tied to disk partitions - an all-or-nothing approach, 
comparing to fsid that would allow cluster filesystem doing its load 
balancing (by
exporting different directories from different nodes)

On the other hand, lock dropping based on "uuid" or "dev_t" may be 
useful in a single server case though.
>
> And please inline your patches into the mail I send, attaching them
> makes it really hard to quote it in mail replies or even to simply read
> it. 
>   
I normally don't do much development works for community versions of 
linux kernel. Some of the "convention" is not clear to me. Will do it 
next time. But these patches tend to be quite large (in terms of line 
count).

-- Wendy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
