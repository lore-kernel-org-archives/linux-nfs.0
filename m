From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 2/4 Revised] NLM - set per fsid grace period
Date: Tue, 10 Apr 2007 10:37:48 -0400
Message-ID: <461BA13C.3080408@redhat.com>
References: <46156F81.8010808@redhat.com> <200704101057.24105.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbHRx-0003Ao-D3
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 07:36:01 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbHRz-0001WV-El
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 07:36:03 -0700
In-Reply-To: <200704101057.24105.okir@lst.de>
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
> On Thursday 05 April 2007 23:52, Wendy Cheng wrote:
>   
>> This change enables per NFS-export entry lockd grace period. The 
>> implementation is based on a double linked list fo_fsid_list that 
>> contains entries of fsid info. It is expected this would not be a 
>> frequent event. The fo_fsid_list is short and the entries expire within 
>> a maximum of 50 seconds.  The grace period setting follows the existing 
>> NLM grace period handling logic and is triggered via echoing the NFS 
>> export filesystem id into nfsd procfs entry as:
>>     
>
> Your patch creates a new per-export structure that is private to lockd.
> It may be easier to put the grace period value into the export entry,
> and check for that in nlm_fopen. It feels more natural than adding
> a whole new shadow export table just for the benefit of lockd.
> (Especially when you consider future extensions like being able
> to search the list by dev_t or uuid or whatever)
>   
I'm traveling so may not be able to do intelligent responses until next 
Monday.

However, I should have made it clear that these patches are minimum 
changes to keep NFS V3 failover going due to large amount of existing 
installations and users. The real efforts and future enhancements should 
be placed on NFS V4. That's the reason most of the code in this patch 
set are stand-alone addition and I have been trying not to mingle the 
changes with main-line nfsd-lockd code.

Ideally we would like to avoid this grace period eventually if we can 
(by transferring the locks from one server to another server without NFS 
clients' involvement). 

-- Wendy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
