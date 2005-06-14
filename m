From: Chris Penney <cpenney@gmail.com>
Subject: Re: NFS tuning - high performance throughput.
Date: Tue, 14 Jun 2005 17:06:15 -0400
Message-ID: <111aefd050614140652112f53@mail.gmail.com>
References: <20050610031144.4B9CA12F8C@sc8-sf-spam2.sourceforge.net>
	 <42AF3B6C.6070901@sohovfx.com>
	 <111aefd050614140472f81157@mail.gmail.com>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Diel9-0001Xs-FS
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 13:45:15 -0700
Received: from wproxy.gmail.com ([64.233.184.194])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Diel9-0007rN-32
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 13:45:15 -0700
Received: by wproxy.gmail.com with SMTP id 57so52303wri
        for <nfs@lists.sourceforge.net>; Wed, 15 Jun 2005 13:45:14 -0700 (PDT)
To: "M. Todd Smith" <todd@sohovfx.com>
In-Reply-To: <111aefd050614140472f81157@mail.gmail.com>
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

> How are you chaining the luns into one volume?  I use the device
> mapper (4 multipath devices =3D> 1 linear).

Sorry, that should be 4 multipath =3D> 1 striped.

   Chris


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
