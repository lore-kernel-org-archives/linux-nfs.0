From: "Henrik Schmiediche" <henrik@stat.tamu.edu>
Subject: RE: Extremely high load on NFS clients wen the NFS server isdown...
Date: Wed, 18 May 2005 14:14:36 -0500
Message-ID: <200505181915.j4IJF6tn011985@s7.stat.tamu.edu>
References: <1116442333.25985.57.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYU0d-0002eT-7w
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:15:11 -0700
Received: from s7.stat.tamu.edu ([165.91.117.61])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYU0a-0001X7-F1
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:15:11 -0700
To: "'Dan Stromberg'" <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1116442333.25985.57.camel@seki.nac.uci.edu>
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


Thanks for the info. I will check out your program.

One more thing, once the NFS server comes back up the load on the client NFS
server system reduces to normal levels. It becomes responsive again.

Sincerely,

    - Henrik

-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Dan Stromberg
Sent: Wednesday, May 18, 2005 1:52 PM
To: Henrik Schmiediche
Cc: strombrg@dcs.nac.uci.edu; nfs@lists.sourceforge.net
Subject: Re: [NFS] Extremely high load on NFS clients wen the NFS server
isdown...

On Wed, 2005-05-18 at 09:28 -0500, Henrik Schmiediche wrote:
>     Hello,
> I have two Redhat AS3 servers. One of them (among other things) serves NFS
> file systems to my other systems including to the other server. When my
NFS
> file server goes down or is restarted the load on the other AS3 server
> increases to the point it is completely useless (it goes to 50+ in a
minute
> or two). I never observed this behavior when I was serving NFS file
systems
> using a Solaris system.
> 
> Has anyone observed this phenomenon?  Any solution to it?
> 
> Sincerely,
> 
>    - Henrik

I've seen this a number of times.  In fact, I just sorted out such a
situation again over the weekend - but running jack the ripper to get a
list of accounts with bad passwords, and digging up one that had a local
shell, rather than a shell on NFS.

Far from a fix, but this program can help a lot when the load on a
system gets so high, and the NFS timeouts are so bad, that you cannot
ssh in or get any other form of interactive shell:

http://dcs.nac.uci.edu/~strombrg/fallback-reboot/

In fact, it can often even allow you reboot a system when the system's
hard disks have gone temporarily useless.

(Yes, it's a shameless plug of my own program :)




-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
