From: Jean-Eric Cuendet <Jean-Eric.Cuendet@linkvest.com>
Subject: Re: rpc.mountd + rpc.nfsd
Date: Tue, 03 Sep 2002 15:45:51 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D74BD0F.1020207@linkvest.com>
References: <3D7363A7.8090906@linkvest.com>	<15732.7907.19389.156631@notabene.cse.unsw.edu.au>	<3D745D10.4040409@linkvest.com>	<15732.35929.482032.954554@notabene.cse.unsw.edu.au>	<3D7490D4.7050307@linkvest.com> <15732.39741.104912.607715@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@sourceforge.net
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

>
>
>I suspect you would be better off starting with am-utils than
>nfs-server. (am-utils is a sophisticated auto-mount daemon).
>
Everyone that I ask about that tell me the same: use amd...
But (except if I miss something), it's absolutely NOT suitable for that!

Explainations:
amd mounts a smb share in the filesystem (say, mounting //server/share 
=> /smb). To mount, you must provide a user/pwd. Then there is some 
mount time fixed uid/gid used to "own" the files on the machine.
If the authentication is done by user1 and then user2 is accessing 
files, the permissions will be checked on user1 on the SMB server, and 
with uid/gid on the client. If user2 has access to files that user1 
haven't, user2 will be denied access...
If user2 have access that user1 don't , access will be granted anyway 
(if uid/gid on the client is OK).

The goal is to check the perms on a per access basis. When user1 access 
files, we use its auth token to check if access is granted. Client 
doesn't anything, only the SMB server makes checks.
Then, if user2 access other files, we use its auth token, which let him 
access different files.
It's the same as network neighborood in Windows. Only files that the 
USER (not the machine) have access are acessible.

Am I missing something with amd?

>If I understand you correctly, the nfs server will be on the same
>machine as the nfs client that accesses that server. And then the
>server reaches out over the network with SMB.
>
Yes, that's it! The nfs-server is only a bridge. Access is only provided 
for 127.0.0.1

>In that case you don't need mountd at all.  When the server starts, it
>mounts itself and then starts responding to NFS requests.
>
Cooool. It's simpler! So, server mounting itself doesn't need mountd. 
How do I do that?
- Implementing NFSD RPC calls.
- Starting NFSD
- Mounting the server (mount -t nfs localhost:/ /smb)
Why isn't mountd  needed? What does it provide that is not needed?

>It is much easier not to re-invent the wheel. For the actual file
>access, don't do that via NFS, simply mount the SMB share using smbfs
>somewhere and direct the client to that. Only use NFS for the browsing.
>
The same problem as explained before...

>I'm not sure about the 'different-users-see-different-things' bit, but
>
That's just the point that don't work and that's very important in this 
thing.

>there are elements of that in Erez' hlfsd (Home Link File System) so I
>suspect he could help there too.
>
I'll have a look at that. But I suspect that it won't change things.

Thanks anyway for everything.
-jec

PS: Are you a RedHat employee or not?




-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
