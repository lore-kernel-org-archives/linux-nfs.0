From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [kNFSD] [PATCH] fixed '-p port' arg to rpc.nfsd plus more.
Date: Tue, 22 Mar 2005 05:17:21 -0500
Message-ID: <423FF0B1.8060007@RedHat.com>
References: <423EDD43.8000209@RedHat.com> <16959.23048.930497.833801@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDgK1-0001wQ-DQ
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 02:09:13 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDgJz-0007z1-VR
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 02:09:13 -0800
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
> I'm happy to consider changes in syntax, but I really don't like
> merging these very different concepts in the one file.

My initial thought is this adds much more complexity that
really needed... All that's needed is to set the port, version
and protocol. As soon as you added in address and address types,
it adds a hole new level complexity that may not be needed,
to solve this particular problem.

but let me take a closer took to see how much is truly need to
create a couple more proc files and well as the parsing
routines to handle theses type of syntaxes....

steved.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
