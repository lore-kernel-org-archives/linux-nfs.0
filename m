From: "Iain Irwin-Powell" <iain@cinesite.co.uk>
Subject: RE: NFS Performance Between SGI Servers and Linux Clients
Date: Wed, 28 May 2003 10:02:27 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00f601c324f7$dd06fa90$0b00430a@granger>
References: <3ECE100C.6060409@cinesite.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "'Lever, Charles'" <Charles.Lever@netapp.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from scanman.cinesite.co.uk ([193.203.81.129])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19KwtF-00034x-00
	for <nfs@lists.sourceforge.net>; Wed, 28 May 2003 02:06:33 -0700
To: "'Danny Smith'" <dannys@cinesite.co.uk>, <trond.myklebust@fys.uio.no>
In-Reply-To: <3ECE100C.6060409@cinesite.co.uk>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Managed to get some quiet time to test the vm.max-readahead tweaking.

This definitely makes a difference to the load average on the SGI server
end. On this test I was only opening 1 file at a time.

Tuning vm.max-readahead down to 8 provided the best combination of
server load to client throughput, although the client throughput was
compromised by the down tuning (no real surprise there).

What I am waiting to get is a 'real world' situation so that I can tune
whilst I am seeing the problem to see if we can make it go away or at
least alleviate the symptoms.

The implication here (to me at least) is that the SGI is having problems
servicing all the requests from the Linux clients. I will feed this back
to SGI and see what they can come up with.

More when I know.

Iain



******************************************************************
Iain Irwin-Powell (AKA Iain Powell)
Senior Systems Administrator
Cinesite Europe Limited
9 Carlisle Street
London
W1D 3BP
 
T: +442079734000
DDI: +442079734053
*******************************************************************
It's not broken, it just doesn't work the way you expected.
*******************************************************************

> -----Original Message-----
> From: Danny Smith [mailto:dannys@cinesite.co.uk]
> Sent: 23 May 2003 13:12
> To: trond.myklebust@fys.uio.no
> Cc: Lever, Charles; Iain Irwin-Powell; nfs@lists.sourceforge.net
> Subject: Re: [NFS] NFS Performance Between SGI Servers and Linux
Clients
> 
> Trond Myklebust wrote:
> 
> >>>>>>" " == Charles Lever <Lever> writes:
> >>>>>>
> >>>>>>
> >
> >     > trond, isn't there a read ahead value in the client that can
be
> >     > tweaked?  he could trim down vm_max_readahead, unless there is
> >     > a max_readahead[] entry for anonymous file systems.
> >
> >That should partly help to trim it down unless the client is reading
> >from > 1 file at a time. In that case the RPC layer will still try to
> >issue more reads (up to MIN(16,vm_max_readahead) requests per
process)
> >if the network and server permits it.
> >
> >Beware, though, that vm_max_readahead will effect not only
> >NFS. Performance on other tasks may suffer.
> >
> >
> I will give this a try in Iain's absence. In the real world we *are*
> likely
> to be reading multiple files, however for testing purposes we don't
have
> to.
> 
> Danny
> 
> --
> Danny Smith
> Senior Systems Administrator, Cinesite (Europe) Ltd
> 020 7973 4000 - x4055    /    dannys@cinesite.co.uk
> 
> 




-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
