From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [kNFSD] [PATCH] fixed '-p port' arg to rpc.nfsd plus more.
Date: Mon, 21 Mar 2005 10:59:47 -0500
Message-ID: <423EEF73.4050302@RedHat.com>
References: <423EDD43.8000209@RedHat.com> <20050321145632.GB20587@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDPJs-0007CK-7z
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 07:59:56 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDPJr-0006pv-36
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 07:59:56 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050321145632.GB20587@fieldses.org>
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

J. Bruce Fields wrote:
> On Mon, Mar 21, 2005 at 09:42:11AM -0500, Steve Dickson wrote:
> 
>>    -N  or  --no-nfs-version vers
>>        This option can be used to request that rpc.nfsd does not  offer
>>        certain  versions of NFS. The current version of rpc.nfsd can
>>        support both NFS version 2,3 and the newer version 4.
> 
> 
> We definitely need something like this, thanks!  Though I would have
> thought something like "--min-version" and "--max-version" would be more
> natural.  (What do other OS's do?)
I was trying to keep the syntax similar to
what rpc.mountd uses. I figured it would be
easier to turn things on and off from a init
script point of view....

But if it makes more sense to do a min/max
type of thing, that could work too...

steved.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
