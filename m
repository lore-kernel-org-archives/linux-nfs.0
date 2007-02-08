From: Jim Davis <jdavis@CS.Arizona.EDU>
Subject: NFSv3 + krb5 home directory problem
Date: Thu, 08 Feb 2007 15:57:06 -0700
Message-ID: <45CBAAC2.1090105@CS.Arizona.EDU>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
	<20070208222750.23464.34565.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFICb-0001bJ-73
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:57:17 -0800
Received: from optima.cs.arizona.edu ([192.12.69.5])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HFICb-0007W3-Tr
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:57:19 -0800
Received: from [172.16.1.9] (bsod.cs.arizona.edu [172.16.1.9])
	by optima.cs.arizona.edu (8.13.4/8.13.4) with ESMTP id l18Mv6Al005634
	for <nfs@lists.sourceforge.net>; Thu, 8 Feb 2007 15:57:08 -0700 (MST)
	(envelope-from jdavis@CS.Arizona.EDU)
In-Reply-To: <20070208222750.23464.34565.stgit@rock.citi.umich.edu>
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

I've been trying to get NFSv3 home directory mounts with sec=krb5
working between a Netapp filer running OnTap 7.0.5 and a Fedora Core 6
client with the latest nfs-* RPMs installed and kernel version
2.6.18-1.2869.fc6.  Our KDCs run FreeBSD 6.1 with the MIT Kerberos
port installed.  Authentication seems to work okay,

Script started on Thu Feb  8 15:31:23 2007
bsod$ /bin/su - testacct
Password:

but the home directory isn't usable.

/bin/su: warning: cannot change directory to /home/testacct: Permission 
denied
-bash: /home/testacct/.bash_profile: Permission denied

The mount though did succeed:

-bash-3.1$ mount | grep testacct
sinagua:/vol/vol0/home/testacct on /home/testacct type nfs 
(rw,nfsvers=3,tcp,timeo=600,rsize=32768,wsize=32768,hard,intr,sec=krb5,addr=172.16.1.252)
-bash-3.1$ grep testacct /etc/auto.home
testacct 
-rw,bg,vers=3,tcp,timeo=600,rsize=32768,wsize=32768,hard,intr,sec=krb5 
sinagua:/vol/vol0/home/testacct

But

-bash-3.1$ klist -e
klist: No credentials cache found (ticket cache FILE:/tmp/krb5cc_500_vZWPDb)


Kerberos 4 ticket cache: /tmp/tkt500
klist: You have no tickets cached

Okay, I thought the PAM stack would provide the credentials.  But even 
after running kinit...

-bash-3.1$ kinit
Password for testacct@CS.ARIZONA.EDU:
-bash-3.1$ cd
-bash: cd: /home/testacct: Permission denied
-bash-3.1$ klist -e
Ticket cache: FILE:/tmp/krb5cc_500_vZWPDb
Default principal: testacct@CS.ARIZONA.EDU

Valid starting     Expires            Service principal
02/08/07 15:32:03  02/09/07 15:32:03  krbtgt/CS.ARIZONA.EDU@CS.ARIZONA.EDU
         renew until 02/08/07 15:32:03, Etype (skey, tkt): Triple DES 
cbc mode with HMAC/sha1, Triple DES cbc mode with HMAC/sha1


Kerberos 4 ticket cache: /tmp/tkt500
klist: You have no tickets cached
-bash-3.1$ exit
logout

...the directory isn't usable

-bash: /home/testacct/.bash_logout: Permission denied
bsod$ exit
exit

Script done on Thu Feb  8 15:32:39 2007

Running rpc.gssd in verbose mode produced

Script started on Thu Feb  8 15:30:29 2007
bsod$ /sbin/lsmod | grep sunrpc
sunrpc                158333  6 
nfs,lockd,nfs_acl,rpcsec_gss_krb5,auth_rpcgss
bsod$ mount | grep rpc_pipe
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
bsod$ sudo strace -o /tmp/rpc.gssd -f /usr/sbin/rpc.gssd -f -vvv
Using keytab file '/etc/krb5.keytab'
Processing keytab entry for principal 
'nfs/bsod.cs.arizona.edu@CS.ARIZONA.EDU'
We will use this entry (nfs/bsod.cs.arizona.edu@CS.ARIZONA.EDU)
Using (machine) credentials cache: 
'MEMORY:/tmp/krb5cc_machine_CS.ARIZONA.EDU'

That's the extent of output while the commands above ran.

And the (enormous) strace output file seems mostly to consist of polling
loops something like

2720  poll([{fd=6, events=POLLIN, revents=POLLERR|POLLHUP}, {fd=0, 
events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, 
events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, 
events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, 
events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, 
events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, 
events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, 
events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, events=0}, {fd=0, 
events=0}, {fd=0, events=0}, {fd=0, events=0}], 32, 500) = 1
2720  chdir("/var/lib/nfs/rpc_pipefs/nfs") = 0
2720  open("/var/lib/nfs/rpc_pipefs/nfs", 
O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 7
2720  fstat64(7, {st_mode=S_IFDIR|0555, st_size=0, ...}) = 0
2720  fcntl64(7, F_SETFD, FD_CLOEXEC)   = 0
2720  getdents64(7, /* 3 entries */, 4096) = 80
2720  getdents64(7, /* 0 entries */, 4096) = 0
2720  close(7)                          = 0

Any ideas?




-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
