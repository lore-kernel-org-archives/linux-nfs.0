From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: rpc.mountd + rpc.nfsd
Date: Tue, 3 Sep 2002 21:21:33 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15732.39741.104912.607715@notabene.cse.unsw.edu.au>
References: <3D7363A7.8090906@linkvest.com>
	<15732.7907.19389.156631@notabene.cse.unsw.edu.au>
	<3D745D10.4040409@linkvest.com>
	<15732.35929.482032.954554@notabene.cse.unsw.edu.au>
	<3D7490D4.7050307@linkvest.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@sourceforge.net,  Erez Zadok <ezk@cs.sunysb.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Jean-Eric Cuendet <jean-eric.cuendet@linkvest.com>
In-Reply-To: message from Jean-Eric Cuendet on Tuesday September 3
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

On Tuesday September 3, jean-eric.cuendet@linkvest.com wrote:
> I'm developing (beginning...) an SMB to NFS bridge.
> That means an NFS server that gets its data, files, ACLs, etc... to SMB 
> servers (Samba or Windows).
> To begin, I'll take the sources of nfs-server userspace. But there is 2 
> daemons while (I think) only one is necessary.
> Would it be OK (In terms of kernel and RPC interactivity) to have only 
> one daemon that do mountd+nfsd?

I suspect you would be better off starting with am-utils than
nfs-server. (am-utils is a sophisticated auto-mount daemon).

If I understand you correctly, the nfs server will be on the same
machine as the nfs client that accesses that server. And then the
server reaches out over the network with SMB.
In that case you don't need mountd at all.  When the server starts, it
mounts itself and then starts responding to NFS requests.

It is much easier not to re-invent the wheel. For the actual file
access, don't do that via NFS, simply mount the SMB share using smbfs
somewhere and direct the client to that. Only use NFS for the browsing.

I suspect that you could possibly just use am-utils as it is and write
some back-end that provided a mount-map that am-utils used.  I suggest
you talk to Erez Zadok <ezk@cs.sunysb.edu>.  He could probably point
you in the right direction.

I'm not sure about the 'different-users-see-different-things' bit, but
there are elements of that in Erez' hlfsd (Home Link File System) so I
suspect he could help there too.


> 
> The goal of this project is to have a fully browseable /smb directory.
> That will be:
> /smb --|-- DOMAIN --|-- SERVER --|-- Share --|-- file
> And all that authenticate in a per user way. That means that all 
> connected users would be able to access /smb while seeing only what 
> their credentials allow them. Even root in the machine won't be able to 
> see every connected user data (root could always dump memory and find 
> credentials..., but it's a lot harder to do than just su - user and go 
> to the NFS mounted dir...)
> 
> What do you think of that?
> 
> -jec
> 
> PS: There is a similar commercial product called sharity 
> (http://www.obdev.at/products/sharity/)


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
