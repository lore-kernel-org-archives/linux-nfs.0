From: Shantanu Goel <sgoel01@yahoo.com>
Subject: Re: Re: [PATCH] Smooth out NFS client writeback
Date: Wed, 29 Jun 2005 15:34:54 -0700 (PDT)
Message-ID: <20050629223454.59273.qmail@web30708.mail.mud.yahoo.com>
References: <42C2C33D.8000308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Shantanu Goel <sgoel01@yahoo.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dnl95-0000Gv-3N
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 15:35:03 -0700
Received: from web30708.mail.mud.yahoo.com ([68.142.200.141])
	by sc8-sf-mx1-new.sourceforge.net with smtp (Exim 4.44)
	id 1Dnl92-00050K-R5
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 15:35:03 -0700
To: Peter Staubach <staubach@redhat.com>,
	"Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <42C2C33D.8000308@redhat.com>
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


> Lever, Charles wrote:
> >committing the whole file at once is simply more
> efficient from a
> >network perspective when an application is
> performing random writes
> >(unless it is using O_SYNC).  there are some cases
> where it won't make a
> >difference whether a range or a whole file commit
> is used, but i think
> >it would be really hard to figure out a client-side
> heuristic to decide
> >which is better.

The patch I posted is actually much better in terms of
the # commit requests it issues compared to the stock
client.  There are some #'s for iozone -r4k -s256m -c:

Proc            Stock         Patch
write           16486         16384
commit            518            80

Here are the numbers for write throughput as seen by
the children in KB/s in the iozone test above to see
the difference that commit range makes.

Stock    Patch w/o commit   Patch w/commit
7064     6038               10226    =20

When I get a chance I'll modify the Linux NFS server
to honour the range as well and see what if any
difference it makes.

Thanks,
Shantanu



	=09
____________________________________________________=20
Yahoo! Sports=20
Rekindle the Rivalries. Sign up for Fantasy Football=20
http://football.fantasysports.yahoo.com


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happen=
ing
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by H=
P,=20
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
