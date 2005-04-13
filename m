From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Problem with NLM on Fedora
Date: Wed, 13 Apr 2005 19:43:55 -0400
Message-ID: <425DAEBB.2000806@RedHat.com>
References: <9E621559095AA746B22B21CD4FAF99A50A4E76@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DLrWk-0007Ft-Oe
	for nfs@lists.sourceforge.net; Wed, 13 Apr 2005 16:44:10 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DLrWe-00029v-SW
	for nfs@lists.sourceforge.net; Wed, 13 Apr 2005 16:44:10 -0700
To: eh@dataconnection.com
In-Reply-To: <9E621559095AA746B22B21CD4FAF99A50A4E76@EDINMAIL1.ad.datcon.co.uk>
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

eh@dataconnection.com wrote:
> I've just installed Fedora, and am having problems with NFS. 
> 
> What I'm seeing is that NLM requests are not issued to the NFS server 
> (which is a SNAP Server).  Instead the application hangs for about 7 
> seconds, and then returns successfully (i.e. the locks are ostensibly 
> granted).  The delay happens both on locks and unlock requests.  Via 
> tcpdump I see NFS requests/responses, but no RPC calls for NLM.
Could you post a bzip2-ed ethereal trace (meaning
tethereal -w /tmp/dump.pcap; bzip2 /tmp/dump.pcap) of this?

There are some know locking issue with FC3
(see: https://bugzilla.redhat.com/beta/show_bug.cgi?id=150151)
but this appears to be a bit different...

steved.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
