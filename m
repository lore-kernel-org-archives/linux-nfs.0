From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: rpc.mountd + rpc.nfsd
Date: Fri, 6 Sep 2002 11:04:35 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15735.65315.384168.574957@notabene.cse.unsw.edu.au>
References: <3D7363A7.8090906@linkvest.com>
	<15732.7907.19389.156631@notabene.cse.unsw.edu.au>
	<3D745D10.4040409@linkvest.com>
	<15732.35929.482032.954554@notabene.cse.unsw.edu.au>
	<3D7490D4.7050307@linkvest.com>
	<15732.39741.104912.607715@notabene.cse.unsw.edu.au>
	<3D74BD0F.1020207@linkvest.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Jean-Eric Cuendet <Jean-Eric.Cuendet@linkvest.com>
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

On Tuesday September 3, Jean-Eric.Cuendet@linkvest.com wrote:
> >
> >
> >I suspect you would be better off starting with am-utils than
> >nfs-server. (am-utils is a sophisticated auto-mount daemon).
> >
> Everyone that I ask about that tell me the same: use amd...
> But (except if I miss something), it's absolutely NOT suitable for that!
> 
> Explainations:
> amd mounts a smb share in the filesystem (say, mounting //server/share 
> => /smb). To mount, you must provide a user/pwd. Then there is some 
> mount time fixed uid/gid used to "own" the files on the machine.
> If the authentication is done by user1 and then user2 is accessing 
> files, the permissions will be checked on user1 on the SMB server, and 
> with uid/gid on the client. If user2 has access to files that user1 
> haven't, user2 will be denied access...
> If user2 have access that user1 don't , access will be granted anyway 
> (if uid/gid on the client is OK).
> 
> The goal is to check the perms on a per access basis. When user1 access 
> files, we use its auth token to check if access is granted. Client 
> doesn't anything, only the SMB server makes checks.
> Then, if user2 access other files, we use its auth token, which let him 
> access different files.
> It's the same as network neighborood in Windows. Only files that the 
> USER (not the machine) have access are acessible.
> 
> Am I missing something with amd?

What you could do is arrange that amd mounts a completely separate
filesystem tree for each user, using something similar to hlfsd to
automatically direct each user to a different tree.  Then each tree
has smb shares mounted with the user's username and password, and only
accessable to that user.

Alternately, you could modify smbfs to open multiple connections to
the server, one for each user, and direct different user's requests
down different connections.

Alternately you could do the whole thing in an NFS server.

I suspect the last would be the hardest, but maybe that's just me.

Have fun.

NeilBrown

> 
> PS: Are you a RedHat employee or not?
> 

not.


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
