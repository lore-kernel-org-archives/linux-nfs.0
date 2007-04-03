From: Phillip <phuang@plasmon.cn>
Subject: can not start NFSv4 with Kerberos 5
Date: Tue, 03 Apr 2007 18:10:20 +0800
Message-ID: <1175595021.3798.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYfyd-0004M0-H0
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 03:11:27 -0700
Received: from [211.97.48.10] (helo=zh.plasmon.cn)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYfyd-0008HU-2q
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 03:11:01 -0700
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

Hi folks,

Currently we plan to use NFSV4 with Kerberos:
KDC: Windows 2K AD

NFSv4 server: CentOS 4.4 with 2.6.20 kernel
# cat /etc/exports
/XFS/NFS4       gss/krb5
(rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync)

Client: CentOS 4.4

When I use Ktpass to create keytab:

C:> Ktpass princ administrator/PLASMON.SIT@PLASMON.SIT mapuser
administrator -pass admin out unixmachine.keytab
C:> Ktpass princ root/PLAMONS.SIT@PLASMON.SIT mapuser root -pass admin
out unixmachine_1.keytab


and copy this output keytabs to NFSv4 server, and then export them with
kinit well.

However, when I attempt to start NFS service, the rpcsvcgssd failed.

Then I try to execute these below commands

[root@nfsv4 kevin]# rpc.svcgssd -fvvv
ERROR: GSS-API: error in gss_import_name(): An invalid name was supplied
- Hostname cannot be canonicalized
unable to obtain root (machine) credentials
do you have a keytab entry for nfs/<your.host>@<YOUR.REALM>
in /etc/krb5.keytab?

[root@nfsv4 kevin]# rpc.gssd -fvvv
Using keytab file '/etc/krb5.keytab'
Processing keytab entry for principal
'administrator/PLASMON.SIT@PLASMON.SIT'
We will NOT use this entry (administrator/PLASMON.SIT@PLASMON.SIT)
Processing keytab entry for principal 'root/PLASMON.SIT@PLASMON.SIT'
We will NOT use this entry (root/PLASMON.SIT@PLASMON.SIT)
ERROR: No usable keytab entries found in keytab '/etc/krb5.keytab'
Do you have a valid keytab entry for nfs/<your.host>@<YOUR.REALM> in
keytab file /etc/krb5.keytab ?
Continuing without (machine) credentials - nfs4 mounts with Kerberos
will fail
processing client list


Did I take mistakes in creating keytab? 


Please help me fix this issue.
Thanks in advance.

Regards,
Phillip




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
