From: Neil Horman <nhorman@redhat.com>
Subject: Re: Problem with NLM on Fedora
Date: Wed, 20 Apr 2005 09:40:08 -0400
Message-ID: <20050420134008.GC8264@hmsendeavour.rdu.redhat.com>
References: <9E621559095AA746B22B21CD4FAF99A50A4EF1@EDINMAIL1.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOFR8-0000Rp-Ao
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 06:40:14 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOFR6-0008UV-Lf
	for nfs@lists.sourceforge.net; Wed, 20 Apr 2005 06:40:14 -0700
To: eh@dataconnection.com
In-Reply-To: <9E621559095AA746B22B21CD4FAF99A50A4EF1@EDINMAIL1.datcon.co.uk>
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

On Thu, Apr 14, 2005 at 11:51:29AM +0100, eh@dataconnection.com wrote:
> Moving my data onto a filer which doesn't expose TCP (and therefore forces use of UDP) seems to work fine.
>  
> So I'm now convinced this isn't a client-side problem.  However I need to work with this particular server, so to work around the server-side problem, I'd still like a way to force NLM connections to use UDP rather than TCP.  
>  
> Anyone know how to do this?
>  
> Edward.
> 
> -----Original Message-----
> From: Edward Hibbert (eh@dataconnection.com) 
> Sent: 14 April 2005 11:06
> To: 'Steve Dickson'
> Cc: nfs@lists.sourceforge.net
> Subject: RE: [NFS] Problem with NLM on Fedora
> 
> 
> 
> Digging a bit deeper, I was wrong to say there are no NLM packets flowing.  Sorry.
> 
> What I think is happening is that the NLM requests are being lost, and the delays I'm seeing are due to retransmission.  One difference that I notice from tcpdump trace is that Fedora is using TCP connections for the NLM traffic, whereas RedHat 8 (running successfully against the same filer) is using UDP.
> 
> Although I'd expect TCP to be more reliable, it's possible that the filer isn't very good at TCP traffic.  TCP support has recently been added to this SNAP model - it only used to use UDP.  So maybe it's flakey.
> 
> Is it possible to force the NLM traffic over UDP from the client side?
> 
> Edward.
> 
I think the NLM client mirrors whatever protocol the NFS client is using, so if
you were to mount the NFS share with proto=udp in the mount options, NLM should
also use udp, rather than tcp.

Regards
Neil

> 
> -----Original Message-----
> From: Steve Dickson [  <mailto:SteveD@redhat.com> mailto:SteveD@redhat.com]
> Sent: 14 April 2005 00:44
> To: Edward Hibbert (eh@dataconnection.com)
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] Problem with NLM on Fedora
> 
> 
> eh@dataconnection.com wrote:
> > I've just installed Fedora, and am having problems with NFS.
> >
> > What I'm seeing is that NLM requests are not issued to the NFS server
> > (which is a SNAP Server).  Instead the application hangs for about 7
> > seconds, and then returns successfully (i.e. the locks are ostensibly
> > granted).  The delay happens both on locks and unlock requests.  Via
> > tcpdump I see NFS requests/responses, but no RPC calls for NLM.
> Could you post a bzip2-ed ethereal trace (meaning
> tethereal -w /tmp/dump.pcap; bzip2 /tmp/dump.pcap) of this?
> 
> There are some know locking issue with FC3
> (see:  <https://bugzilla.redhat.com/beta/show_bug.cgi?id=150151> https://bugzilla.redhat.com/beta/show_bug.cgi?id=150151)
> but this appears to be a bit different...
> 
> steved.
> 
> 

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
