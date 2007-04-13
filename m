From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 3/4 Revised] NLM - kernel lockd-statd changes
Date: Fri, 13 Apr 2007 15:31:03 -0400
Message-ID: <461FDA77.5080009@redhat.com>
References: <46156FA0.4030506@redhat.com> <200704101109.44333.okir@lst.de>
	<17948.26876.426822.963222@notabene.brown>
	<20070413191615.GU1804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, cluster-devel@redhat.com,
	nfs@lists.sourceforge.net
To: Lon Hohberger <lhh@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcRSM-0003kt-07
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 12:29:14 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HcRSO-00024P-8w
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 12:29:16 -0700
In-Reply-To: <20070413191615.GU1804@redhat.com>
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

Lon Hohberger wrote:
> On Wed, Apr 11, 2007 at 02:50:04PM +1000, Neil Brown wrote:
>   
>> lockd knows which is which either based on the destination network
>> address of the lock request, or the filesystem on which the lock was
>> taken.   Somehow this information needs to get communicated to statd
>> so that different 'sm' directories can be used.  my_name seems a
>> sensible place to put the information.
>>     
>
> Right.  Using the inbound-destination address instead of fsid or file
> system will ensure the right address is used for sending the SM_NOTIFY
> requests.  However, fsid, or export path - on a service with more than
> one network address will not, I think...
>   

So I think we conclude here that inbound-destination address is required 
for SM_NOTIFY purpose.

Thanks for all the comments. Will summarize the issues on Monday and see 
what we should go from there.

-- Wendy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
