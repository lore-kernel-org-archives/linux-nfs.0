From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [kNFSD] [PATCH] fixed '-p port' arg to rpc.nfsd plus more.
Date: Tue, 22 Mar 2005 07:27:19 -0500
Message-ID: <42400F27.8010305@RedHat.com>
References: <423EDD43.8000209@RedHat.com> <16959.23048.930497.833801@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDiLu-0007wc-2x
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 04:19:18 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDiLd-0004ds-99
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 04:19:17 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16959.23048.930497.833801@cse.unsw.edu.au>
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

Neil Brown wrote:
> 
> I would rather (I think) have two new files
>    /proc/fs/nfsd/version
> and
>    /proc/fs/nfsd/ports
Hmm... I think there is a timing issue here.
These have to be set before threads since
write_threads() does the nfsd_svc(), true?

How about changing the name of the file rpc.nfsd
writes to? To something like /proc/fs/nfsd/config?

rpc.nfsd could write to nfsd/config which then could
cause the version, ports and threads files to have
the correct information....


steved.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
