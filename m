From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [KNFSD] [PATCH] fixed '-p port' arg to rpc.nfsd plus more.
Date: Mon, 21 Mar 2005 11:22:38 -0500
Message-ID: <423EF4CE.90501@RedHat.com>
References: <423EDD43.8000209@RedHat.com> <20050321154645.GE1736@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDPfx-0008LK-Nu
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 08:22:45 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDPfw-0001Bp-KH
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 08:22:46 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20050321154645.GE1736@perlsupport.com>
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

Chip Salzenberg wrote:
> According to Steve Dickson:
> 
>>    -N  or  --no-nfs-version vers
>>        This option can be used to request that rpc.nfsd does not  offer
>>        certain  versions of NFS. The current version of rpc.nfsd can
>>        support both NFS version 2,3 and the newer version 4.
> 
> 
> Thanks very much for the patches, but would you please add on support
> for the '-V' flag specifying the versions that should be allowed?
Well since everything is on by default, I figured all that
was needed was a way to turn things off, but it would
be a non-issue to add.

> 
> 
>>    -T  or  --no-tcp
>>        Disable rpc.nfsd from accepting TCP connections from clients.
>>
>>    -U  or  --no-udp
>>        Disable rpc.nfsd from accepting UDP connections from clients.
> 
> 
> And could you please document when (if ever) these options would be
> useful to an end user?
I was thinking servers behind firewalls might want to
explicitly define one protocol or the other, just
to keep things simple and I know other servers have
these options.


steved.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
