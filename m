From: Stuart Sheldon <stu@actusa.net>
Subject: Re: NFS on a freeswan gateway?
Date: Mon, 24 Jun 2002 17:06:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D17B3F7.1010301@actusa.net>
References: <20020624223641.GA16108@backlot.linas.org> <shsptygs21r.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Linas Vepstas <linas@linas.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dns1.actusa.net ([205.147.44.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Mdqh-0001D5-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Jun 2002 17:06:23 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Linas,

This looks to me to be a configuration issue. RPC always and has always 
presented it's default route interface IP when connecting. If you are 
attempting to mount to an NFS server on a network that is reachable from the 
inside interface, you would need to add the default interface IP to your 
/etc/exports file. If you are trying to go across the IPSec tunnel to attach 
to an NFS server on the other side, you need to add a second connection in the 
ipsec.conf file for the ipsec computer it self...

Maybe I'm missing something, but tests show that this will work as advertised...

Stu


Trond Myklebust wrote:
>>>>>>" " == Linas Vepstas <linas@linas.org> writes:
>>>>>
> 
>      > Hi, I am resending a message sent to the freeswan mailing list.
>      > As explained below, the default IP source address used in nfs
>      > mount requests is sometimes 'not appropriate' for certain
>      > packet-filtering/freeswan setups.
> 
>      > I'd like to patch that part of the nfs/rpc client so that it
>      > uses an IP source address that is routing-wise 'closer' to the
>      > nfs server.  But I have damned little experience with the nfs
>      > kernel code (or nfs internals), and thus would like an opinion,
>      > or commnts, or, best yet, a pointer to a pre-existing patch.
> 
> Both the client and the server use the standard IP socket layer
> code. There is no magic... IOW if ordinary sendmsg()/recvmsg() of UDP
> packets over the ipsec0 interface works (and the resulting address in
> the struct msghdr is correct) then NFS should work fine.
> 
> If, however, you are trying to use NAT or masquerading or something
> like that on the FreeSWAM gateways in order to translate 'internal
> addresses' into 'external addresses', then you are screwed: NAT is not
> an appropriate protocol for UDP services.
> 
> Cheers,
>   Trond
> 
> 
> -------------------------------------------------------
> Sponsored by:
> ThinkGeek at http://www.ThinkGeek.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
