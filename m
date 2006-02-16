From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Stale handle error on RHEL4 (2.6.9-22.ELsmp)
Date: Thu, 16 Feb 2006 07:14:17 -0800 (PST)
Message-ID: <20060216151417.42042.qmail@web51611.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9kpw-0003AM-Po
	for nfs@lists.sourceforge.net; Thu, 16 Feb 2006 07:14:28 -0800
Received: from web51611.mail.yahoo.com ([68.142.224.84])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1F9kpv-000694-6t
	for nfs@lists.sourceforge.net; Thu, 16 Feb 2006 07:14:28 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,
    When nfs(v4) server fails over from one system to=20
    other it gets stale handle error.
    All systems have RHEL4 installed (same kernel)
    uname -a  =3D 2.6.9-22.ELsmp #1 SMP=20
   =20

    Details :

[root@vcslinux118 bin]# mount
<---snip>
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
nfsd on /proc/fs/nfsd type nfsd (rw)
/dev/sdi2 on /dir2 type ext3 (rw)
/dev/sdi1 on /dir1 type ext3 (rw)
/dir2 on /export/exp2 type bind (rw,bind)
/dir1 on /export/exp1 type bind (rw,bind)
</---snip>

[root@vcslinux118 bin]# exportfs -v
/export/exp1  =20
<world>(rw,wdelay,nohide,no_root_squash)
/export/exp2  =20
<world>(rw,wdelay,nohide,no_root_squash)
/export       =20
<world>(rw,wdelay,nohide,no_root_squash,fsid=3D0)
[root@vcslinux118 bin]# uname -a
Linux vcslinux118.vxindia.veritas.com 2.6.9-22.ELsmp
#1 SMP Mon Sep 19 18:00:54 EDT 2005 x86_64 x86_64
x86_64 GNU/Linux

I have mounted this on client as=20
#mount -t nfs4 10.212.102.70:/ /kiran

After failover i get stale handle error on client.
Is this a known issue ?

thanks,
 kiran
   =20

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D103432&bid=3D230486&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
