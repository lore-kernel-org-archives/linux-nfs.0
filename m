From: Nicolas Brainez <nbml@many.be>
Subject: permissions
Date: 08 Jul 2002 10:04:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1026115444.20929.11.camel@nicolasb>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

Hi,

I use NFS v2, servers and workstations use Debian woody.


Every user in the LAN have one access to the NFS server (private
directory), no problem with that.
Now I want to set up a 'public' directory to be mounted in NFS, with
full permissions for every user in the LAN IP range.
I tried :

/dir/exported/public 192.168.0.0/24(all_squash)

It works but only when logged in root on workstations (that's logic).
Is it possible to mount this NFS partition with local uid/gid like with
samba ?

If not, have you already done this type of configuration ? how to give
read/write access to everyone ?

Thanks in advance.

--
Nicolas Brainez




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Oh, it's good to be a geek.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
