From: Spencer Shepler <shepler@eng.sun.com>
Subject: Re: mountd role?
Date: Tue, 3 Sep 2002 20:54:26 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020904015426.GX100366@dhcp-uaus08-128-212.sun.com>
References: <3D755A0C.8030203@linkvest.com>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS <NFS@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Jean-Eric Cuendet <jean-eric.cuendet@linkvest.com>
In-Reply-To: <3D755A0C.8030203@linkvest.com>
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

On Wed, Jean-Eric Cuendet wrote:
> Hi,
> I don't understand what the mountd daemon role is?
> There is 2 things:
> - mounting => mountd
> - serving files/dirlist/acls/... => nfsd
> (I think it's correct...)
> 
> What is EXACTLY doing mountd.
> Please be precise.

The NFS protocols (versions 2 and 3) use a shorthand reference called
a filehandle to refer to specific filesystem objects.  The user and
traditional operation system filesystem mechanisms use a pathname.
Therefore, a method to bootstrap between pathname and filehandle must
be available to the NFS client.  For NFS version 2 and 3, this
bootstrap mechanism is implemented by the MOUNT protocol and has
traditionally been implemented by a user level mountd daemon.  The
mountd daemon has also been tasked with enumeration of available
security mechanisms for crude security negotiation between client and
server.

There is nothing in the MOUNT protocol that prohibits an
implementation from being done in the kernel nor done on the same
TCP/UDP port that the NFS server is provided on.  But since it is a
separate RPC program from the NFS program, it must be demutiplexed as
appropriate if it were implemented on the same port as NFS (or other
RPC programs).

BTW: you imply that the traditional nfsd provides ACL service.  This
is not true for NFS version 2 and 3.  All current implementations that
offer NFS ACL service do so by non-standard RPC programs that are
implemented in conjunction with the NFS server.

A good reference for the NFS version 2 and 3 protocols is Brent
Callaghan's book "NFS illustrated".  You might consider purchasing or
borrowing a copy.

Spencer


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
