From: Peter Staubach <staubach@redhat.com>
Subject: Re: Re: [PATCH] Smooth out NFS client writeback
Date: Wed, 29 Jun 2005 11:50:21 -0400
Message-ID: <42C2C33D.8000308@redhat.com>
References: <482A3FA0050D21419C269D13989C611307CF4CE7@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Shantanu Goel <sgoel01@yahoo.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dnet9-00064Z-8h
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 08:54:11 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Dnet8-0001qQ-Gw
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 08:54:11 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611307CF4CE7@lavender-fe.eng.netapp.com>
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

Lever, Charles wrote:

>>I don't think that there will be more over the wire 
>>operations generated
>>when using the range versus always specifying the entire 
>>file.
>>    
>>
>
>committing the whole file at once is simply more efficient from a
>network perspective when an application is performing random writes
>(unless it is using O_SYNC).  there are some cases where it won't make a
>difference whether a range or a whole file commit is used, but i think
>it would be really hard to figure out a client-side heuristic to decide
>which is better.
>
>  
>

The network perspective is important, to be sure.  However, so is disk
i/o.

Having done an implementation, it isn't so hard to develop the heuristics,
actually.

Please keep in mind that COMMIT operations are very expensive.  They are
to be avoided whenever possible.  Clients should delay as long as possible
to commit data because they may be able to avoid committing it at all.
These benefits can include data which is repeatedly overwritten, small
writes to the same file system block on the server, temporary files, etc.
The list goes on and on.  Not going to stable storage on the server is a
huge win in performance all that way around.

>>I would claim that a client,
>>which simply issues a blanket COMMIT(0,0), without already 
>>having gathered
>>up the buffers/pages/whatever that need committing, is 
>>broken.  It will be
>>unsafe because it will be subject to races like more data 
>>getting written
>>with UNSTABLE while the COMMIT is happening.  This new data 
>>may or may not
>>have been committed by the COMMIT.
>>    
>>
>
>the linux client already keeps track of the order of writes and commits
>well enough that this isn't an issue.
>
>  
>

Good to hear!

>>Bottom line for me -- if the client can do something to help 
>>the server to
>>help the client and it is an overall win, then I think that 
>>it should do so...
>>    
>>
>
>we're talking about potentially adding complexity to the client and
>increasing the number of write and commit operations on the wire, which
>could have a negative performance impact in other environments (think
>WAN).  all this to optimize a particular workload against a particular
>server implementation.
>
>i'm not saying this type of work shouldn't be explored, but as we
>consider the change, we should be very careful especially since we don't
>have adequate performance regression test coverage yet.
>  
>

I think that there may be more server implementations out there that
could benefit from the client strategy than just the Solaris with UFS
NFS server.  I would guess that most, if not all, would benefit.  I
even suspect that we could make the Linux server go faster if it paid
attention to the byte range specified, instead of always sync'ing the
entire file.  The cost of looking at clean pages/buffers is small, but
adds up quickly...  :-)

       ps


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
