From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: Re: fstab entry with mountprog=,nfsprog= and mount hanging
Date: Tue, 10 Sep 2002 15:30:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020910152959.A12513@hermes.centre-cired.fr>
References: <20020906181313.I23802@hermes.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ol6x-0006BH-00
	for <nfs@lists.sourceforge.net>; Tue, 10 Sep 2002 06:31:23 -0700
Received: from hermes.centre-cired.fr ([193.51.120.92])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id PAA00594
          for <nfs@lists.sourceforge.net>; Tue, 10 Sep 2002 15:28:20 +0100 (WEST)
Received: (from dumas@localhost)
	by hermes.centre-cired.fr (8.11.6/8.11.6) id g8ADU1S13073
	for nfs@lists.sourceforge.net; Tue, 10 Sep 2002 15:30:01 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20020906181313.I23802@hermes.centre-cired.fr>; from dumas@centre-cired.fr on Fri, Sep 06, 2002 at 06:13:13PM +0200
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

On Fri, Sep 06, 2002 at 06:13:13PM +0200, Patrice DUMAS - DOCT wrote:
> Hi,
> 
> I am using intensively mountprog= and nfsprog= options (because I tunnel nfs).
> I have a redhat 7.3 kernel 2.4.18, mount-2.11n.

I follow up on my own post, as I found the reason of all that, and also a 
simpler case in which such a bad thing could happen.

Suppose you have started mountd on the server, but not yet nfsd, and then,
on a client you mount a filesystem from the server. As 100003 is not allready
registered, mount returns 2049 as port. The nfs client is stuck because
nfsd isn't allready started. Now imagine that you start nfsd on the server
on another port that 2049. The nfs client will never rebind with portmap, 
and get stuck forever.

I think that setting autobind for the nfs client should be enough ?

Maybe if it is still required to use 2049 as port when portmap fails, it 
could be possible to add a field to the rpc_client, like default_port, and 
if portmap binding fails, instead of returning a bad status, set the port
to that default_port (in pmap_getport_done). Does it looks right ?

Pat


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
