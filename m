From: parinay <parinay@gmail.com>
Subject: Kerberized NFS v2/v3
Date: Fri, 24 Mar 2006 16:13:18 +0530
Message-ID: <ea2ed4af0603240243n220f1a20o62bfb9910ebf1698@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FMjlN-0003gO-LZ
	for nfs@lists.sourceforge.net; Fri, 24 Mar 2006 02:43:25 -0800
Received: from xproxy.gmail.com ([66.249.82.204])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FMjlN-0005HI-EH
	for nfs@lists.sourceforge.net; Fri, 24 Mar 2006 02:43:25 -0800
Received: by xproxy.gmail.com with SMTP id s16so472281wxc
        for <nfs@lists.sourceforge.net>; Fri, 24 Mar 2006 02:43:19 -0800 (PST)
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
While trying to mount an export with '-sec=3Dkrb5', on linux client, I
am getting this error,
"mount: 10.55.60.142:/vol/fornfs failed, security flavor not supported"
I am trying to get into 'What kerberos is all about?'.But any help on setti=
ng up
a kerberised NFS v2/v3 client would be helpful.
My prime questions are,
            1. Where can I get the information about generating /etc/krb5.k=
eytab
                 My scenario is , I am using Microsoft Active Directory KDC=
.
            2. The patches for bugs,in RH bugzilla's 142464 and 146703.
                Where can I get the patches for my kernel/distro ?
                Can I get a individual patchs instead of a source RPM ?

Steps I have followed so far:
1.add new file /etc/sysconfig/nfs containing "SECURE_NFS=3Dyes"
2.edit /etc/init.d/rpcgssd
  added,"/sbin/modprobe rpcsec_gss_krb5"
4.use "authconfig" to update /etc/krb5.conf and /etc/pam.d/system-auth

My NFS client details:
Distro: Fedora core 3
Kernel:2.6.15-6
.config
# Network File Systems
#
CONFIG_NFS_FS=3Dm
CONFIG_NFS_V3=3Dy
CONFIG_NFS_V3_ACL=3Dy
CONFIG_NFS_V4=3Dy
CONFIG_NFS_DIRECTIO=3Dy
CONFIG_NFSD=3Dm
CONFIG_NFSD_V2_ACL=3Dy
CONFIG_NFSD_V3=3Dy
CONFIG_NFSD_V3_ACL=3Dy
CONFIG_NFSD_V4=3Dy
CONFIG_NFSD_TCP=3Dy
CONFIG_LOCKD=3Dm
CONFIG_LOCKD_V4=3Dy
CONFIG_EXPORTFS=3Dm
CONFIG_NFS_ACL_SUPPORT=3Dm
CONFIG_NFS_COMMON=3Dy
CONFIG_SUNRPC=3Dm
CONFIG_SUNRPC_GSS=3Dm
CONFIG_RPCSEC_GSS_KRB5=3Dm
CONFIG_RPCSEC_GSS_SPKM3=3Dm
Krb packages on machine:
[root@akam ~]# rpm -qa | grep -i krb
krb5-auth-dialog-0.2-1
krb5-server-1.3.4-7
krbafs-utils-1.2.2-6
pam_krb5-2.1.2-1
krb5-workstation-1.3.4-7
krb5-devel-1.3.4-7
krb5-libs-1.3.4-7
krbafs-1.2.2-6
krbafs-devel-1.2.2-6
nfs-utils on machine
nfs-utils-1.0.6-39
system-config-nfs-1.2.8-1
Command executed.
mount  10.55.60.142:/vol/fornfs /mnt/nfs1
Result:
mount: 10.55.60.142:/vol/fornfs failed, security flavor not supported

Sorry for the length of the mail.
thanks & regards,
parinay

--
easy is right
begin right and you're easy
continue easy and you're right
the right way to go easy is to forget the right way
and forget that the going is easy....


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
