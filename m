From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 33/33] knfsd: Support adding transports by writing portlist
	file
Date: Wed, 3 Oct 2007 20:27:19 +1000
Message-ID: <20071003102719.GL21388@sgi.com>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050243.12677.15463.stgit@dell3.ogc.int>
	<18172.34744.784138.666846@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id1NI-0002gz-MV
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 03:22:40 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Id1NL-0004eh-HG
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 03:22:45 -0700
In-Reply-To: <18172.34744.784138.666846@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Sep 28, 2007 at 02:48:56PM +1000, Neil Brown wrote:
> On Thursday September 27, tom@opengridcomputing.com wrote:
> > 
> > Update the write handler for the portlist file to allow creating new
> > listening endpoints on a transport. The general form of the string is:
> > 
> > <transport_name><space><port number>
> > 
> > For example:
> > 
> > tcp 2049
> > 
> > This is intended to support the creation of a listening endpoint for
> > RDMA transports without adding #ifdef code to the nfssvc.c file.
> > The general idea is that the rpc.nfsd program would read the transports
> > file and then write the portlist file to create listening endpoints
> > for all or selected transports. The current mechanism of writing an
> > fd would become obsolete.
> 
> Nuh.
> I'll only accept
>       rdma 2049
> (or whatever) because there seems to be no other way to do it.
> Writing an 'fd' is the *preferred* way.
> 
> There is more to binding an endpoint than protocol and port number.
> There is also local address and I'm not convinced that someone might
> come up with some other way they want to pre-condition a socket.
> 
> If there was any way to associate an RDMA endpoint with a
> filedescriptor,

The whole point of RDMA is not to have a file descriptor or any of that
slow stuff like read(), write(), or reliable connections in software.
(Of course you also lose helpful things like strace, tethereal, and
iptables.  Swings...roundabouts.)

In the case of the local address, you could pass that into the
portlist file too, like:

echo 'tcp 192.168.0.1:2049' > /proc/fs/nfsd/portlist

Or perhaps

echo '23/rdma' > /proc/fs/nfsd/portlist

where 23 is the same file descriptor passed for TCP?


> I would much prefer that 'rpc.nfsd' does that and passes
> down the filedescriptor.  If RDMA is so no-Unix-like (rant rant..)
> that there is no such file descriptor, then I guess we can live with 
> getting the kernel to open the connection.

It's as unUnixlike as you can imagine :-/

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
