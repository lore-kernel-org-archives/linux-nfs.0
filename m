From: Spencer Shepler <shepler@eng.sun.com>
Subject: Re: NFS v4 questions
Date: Wed, 10 Apr 2002 15:43:12 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020410154312.N100393@dhcp-aus08-191.sun.com>
References: <3CB44D46.6020401@linkvest.com>
Reply-To: shepler@eng.sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Jean-Eric Cuendet <jean-eric.cuendet@linkvest.com>
In-Reply-To: <3CB44D46.6020401@linkvest.com>
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
> I have questions related to NFSv4
> Will NFSv4 be able to check file access on a per file basis or like with 
> NFSv3, on a per share basis?
> Will NFSv4 be like AFS or SMB speaking of ACL? And speaking of file 
> access? (Like /afs available to anyone but files/dirs in it being 
> checked for permissions on a file basis based on the krb5/afs ticket)

An NFS server generally share/exports a particular filesystem resource
to clients; this has not changed with NFSv4.  In fact, NFSv4 does not
specify exactly how resources are determined for access by a set of
clients.  However, most implementations will continue to follow the
model of exporting a particular directory and the contents underneath
that directory.  Most implementations that I am aware of will continue
with the model of exporting to a set of clients but this is not
necessary.  With the use of kerberos/spkm3/lipkey, an NFS server can
verify a user's credentials against directory/file ownership to
enforce appropriate access.

NFSv4 does define an ACL attribute so the client and server have a
mechanism to get and set the ACLs for a directory/file.  However, ACL
can always be applied to the server's filesystem objects directly and
will be enforced there regardless of support in the filesystem
protocol.

-- 
Spencer


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
