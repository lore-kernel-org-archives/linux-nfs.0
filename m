From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2 feature requests for lockd
Date: 14 Jun 2002 14:27:36 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsd6uu3v0n.fsf@charged.uio.no>
References: <20020612162643.F10338@hermes.centre-cired.fr>
	<shsr8jaj3ew.fsf@charged.uio.no>
	<20020614140522.D3312@hermes.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17IqBa-0002Jq-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Jun 2002 05:28:15 -0700
To: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
In-Reply-To: <20020614140522.D3312@hermes.centre-cired.fr>
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

>>>>> " " == Patrice DUMAS <dumas@centre-cired.fr> writes:

    >> Tunnelling should be done by setting up a proper virtual
    >> point-to-point interface. That would do the job without needing
    >> any of these hacks.

     > I agree again, but the point in tunneling rpc based services
     > through ssh like with sec_rpc, is that it is quite easy to set
     > up, almost off the box. Maybe there exists point-to-point
     > solutions as easy to set up but I don't know them.

In that case, if there is sufficient demand for it, perhaps this would
be a project worth investigating in its own right? I must admit that I
for one am still not entirely sure which tool is best for the job: I
once suggested the TUN/TAP interface, but perhaps there are better
candidates?

The point is that we don't want to have to reinvent the wheel for NFS,
then SMBFS, CIFS, <insert flavour-of-the-month-networking-filesystem
here>. In particular if this will involve unnecessary messing about
with new incompatible APIs for the NFS utilities and mount programs,
then I for one don't want to know. At least not until somebody has
seriously looked into how much work the business of "doing it right"
would involve.

Cheers,
  Trond

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas - http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
