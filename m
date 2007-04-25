From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 0/4 Revised] NLM - lock failover
Date: Wed, 25 Apr 2007 10:10:31 -0400
Message-ID: <462F6157.7060604@redhat.com>
References: <46156F3F.3070606@redhat.com> <20070425141818.GA14729@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgiXA-0004LS-SE
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 07:31:53 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgiXD-00015p-8P
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 07:31:55 -0700
In-Reply-To: <20070425141818.GA14729@fieldses.org>
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

J. Bruce Fields wrote:
> On Thu, Apr 05, 2007 at 05:50:55PM -0400, Wendy Cheng wrote:
>   
>> 1) Failover server exports filesystem with "fsid" option as:
>>     /etc/exports entry> /mnt/shared/exports *(fsid=1234,sync,rw)
>> 2) Failover server dispatch rpc.statd with "-H" option.
>> 3) Failover server drops locks based on fsid by:
>>     shell> echo 1234 > /proc/fs/nfsd/nlm_unlock
>> 4) Takeover server enters per fsid grace period by:
>>     shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace
>> 5) Takeover server notifies clients for lock reclaim by:
>>     shell> /usr/sbin/sm-notify -f -v floating_ip_address -P an_sm_directory
>>     
>
> I don't understand statd and lockd as well as I should.  Where exactly
> does the takeover server stop serving requests, and the failover server
> start?  If this isn't done carefully, you can leave a window between
> steps 3 and 4 where a client could acquire a lock before its rightful
> owner reclaims it, right?
>
>   
The detailed overall steps were described in the first email we sent 
*long* time (> 6 months, I think) ago. The first step of the whole 
process is tearing down the floating IP from the failover server. The IP 
is not accessible until filesystem is safely fail-over and SM_NOTIFY 
ready to be sent.

Last round of discussion gave me an impression that as long as I rebased 
the code into akpm's mm tree, these patches would get accepted. So I 
have been quite careless in this submission and just realized people 
have a very short memory :) .. Will do the write-up and put it somewhere 
so we don't need to go thru this again.

-- Wendy


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
