From: Jonathan Schreiter <jonathanschreiter@yahoo.com>
Subject: nfs4 with kerberos troubles
Date: Wed, 14 Mar 2007 20:15:05 -0700 (PDT)
Message-ID: <904836.85940.qm@web34407.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRgQt-0007iC-TN
	for nfs@lists.sourceforge.net; Wed, 14 Mar 2007 20:15:25 -0700
Received: from web34407.mail.mud.yahoo.com ([66.163.178.156])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HRgQp-0000Q0-Qx
	for nfs@lists.sourceforge.net; Wed, 14 Mar 2007 20:15:13 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi all,
I've been strugling to get NFS4 to work with my MIT Kerberos 5 infrastucture.  I have a server and client with Centos 4.4.  I'm using LDAP (Fedora Directory Server 1.4) for my POSIX accounts and KRB5 for the authentication.  I am able to get the NFS mounts to work when kerberos is not enabled.

The error from the mount command # mount -t nfs4 -o sec=krb5 mynfsserver:/ /home/NFS4 is:
Warning: rpc.gssd appears not to be running.
mount: block device mynfsserver:/ is write-protected, mounting read-only
mount: cannot mount block device mynfsserver:/ read-only

When I run rpc.gssd -f vvvvvvv from the client, the error I'm seeing is:
WARNING: Failed to create krb5 context for user with uid 0 with any credentials cache for server mynfsserver.mydomain.com

On the server, in /var/log/messages:
mountd[2517]: mount request from unknown host myclientipaddress for /home/NFS4 (/home/NFS4)

I've got portmap, rpcidmapd, nfs, rpcgssd, and rpcsvcgssd services running on both client and server (but I'm not sure all are required on both).

I have created a host and nfs principal and have ktadded them to both the client and server:
#ktlist -k /etc/krb5.keytab
server:
nfs/myserver.mydomain.com@MYREALM.COM
host/myserver.mydomain.com@MYREALM.COM

client:
nfs/myclient.mydomain.com@MYREALM.COM
host/myserver.mydomain.com@MYREALM.COM

note: mydomain.com = MYREALM.COM (but realm is all uppercase)

I only found one other post referencing this, but it recommended the error be in the /etc/krb5.conf.  I have: 
.mydomain.com = MYREALM.COM
mydomain.com = MYREALM.COM
.mydomain.com = myrealm.com

I've also turned off nfslock and iptables services (latter for testing).

nfs server:
-----------
/etc/exports
/home/NFS4 gss/krb5(rw,fsid=0,insecure,no_subtree_check)

/etc/fstab:
/dev/VolGroup00/LogVol02 /home ext3 rw,acl 1 2

/etc/sysconfig/nfs
SECURE_NFS=yes
RPCNFSDCOUNT=8

/etc/idmapd.conf
Pipefs-Directory = /var/lib/nfs/rpc_pipefs
Domain = mydomain.com
Nobody-User = nfsnobody
Nobody-Group = nfsnobody
Method = nsswitch

nfs client:
-----------
/etc/sysconfig/nfs
SECURE_NFS=yes
RPCNFSDCOUNT=8

/etc/idmapd.conf
Pipefs-Directory = /var/lib/nfs/rpc_pipefs
Domain = mydomain.com
Nobody-User = nfsnobody
Nobody-Group = nfsnobody
Method = nsswitch

Can anyone please point me in the correct direction?

Many thanks!
Jonathan

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
