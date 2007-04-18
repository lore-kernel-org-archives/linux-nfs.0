From: "Gregory Baker" <gregory.baker@amd.com>
Subject: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Wed, 18 Apr 2007 16:53:38 -0500
Message-ID: <46269362.5040608@amd.com>
Reply-To: gregory.baker@amd.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: julia bauer <julia.bauer@amd.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeI6Z-0005e4-DW
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 14:54:23 -0700
Received: from outbound-cpk.frontbridge.com ([207.46.163.16]
	helo=outbound1-cpk-R.bigfish.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HeI6a-0001CY-2N
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 14:54:26 -0700
Received: from outbound1-cpk.bigfish.com (localhost [127.0.0.1])
	by outbound1-cpk-R.bigfish.com (Postfix) with ESMTP id A1CA033007E
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 21:51:37 +0000 (UTC)
Received: from mail20-cpk-R.bigfish.com (unknown [10.2.40.3])
	by outbound1-cpk.bigfish.com (Postfix) with ESMTP id 969975A004B
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 21:51:37 +0000 (UTC)
Received: from mail20-cpk (localhost [127.0.0.1])
	by mail20-cpk-R.bigfish.com (Postfix) with ESMTP id 21BE52500C6
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 21:53:55 +0000 (UTC)
Received: from ausb3extmailp01.amd.com (unknown [163.181.251.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail20-cpk.bigfish.com (Postfix) with ESMTP id D15D7BA805D
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 21:53:54 +0000 (UTC)
Received: from SAUSGW02.amd.com (sausgw02.amd.com [163.181.250.22])
	by ausb3extmailp01.amd.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id
	l3ILrilB030630
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 16:53:48 -0500
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



Note I have cases open with Redhat and Netapp, but was curious if other 
people have also seen inconsistent mount attributes (ro/rw) when 
mounting RHEL5 client vs. Netapp 7.2 Ontap.

---+ System environment

[greg@adcgar04 greg]$ uname -a
Linux adcgar04 2.6.18-8.el5 #1 SMP Fri Jan 26 14:15:14 EST 2007 x86_64 
unknown unknown GNU/Linux

[greg@adcgar04 greg]$ rpm -qa | grep nfs-utils
nfs-utils-1.0.9-16.el5
nfs-utils-lib-1.0.8-7.2
nfs-utils-lib-devel-1.0.8-7.2
nfs-utils-lib-1.0.8-7.2
nfs-utils-lib-devel-1.0.8-7.2

[greg@adcgar04 greg]$ mount -V
mount (util-linux 2.13-pre7)

---+ NFS server (Netapp) environment

[greg@apathy greg]$ sudo rsh eng version
NetApp Release 7.2P4: Tue Nov 28 02:55:54 PST 2006

---++ NFS export file entry

[greg@apathy greg]$ sudo rsh eng exportfs | grep pandora

/vol/vol4/pandora 
-sec=sys,ro,rw=@volexport-pandora,root=@volexport-pandora,anon=4058

---++ netgroup member (for export file entry above)

[greg@apathy greg]$ show_netgroup volexport-pandora | grep adcgar
adcgar04.amd.com

---+ Demonstration of inconsistent ro/rw mount reporting

[root@adcgar04 /]# mount eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2

[root@adcgar04 /]# mount -v | grep mnt2
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 on /mnt2 type nfs 
(rw,addr=163.181.34.137)

[root@adcgar04 /]# cat /proc/mounts | grep mnt2
eng:/vol/vol4/pandora/pandora-k26_g25_64-2 /mnt2 nfs 
ro,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=eng 
0 0

[root@adcgar04 /]# cd /mnt2/

[root@adcgar04 mnt2]# touch asdf
touch: cannot touch `asdf': Read-only file system

---+ Discussion

---++Linux (RHEL3/4) NFS servers that have similiar exportfs options

/tmp    *(ro,anonuid=4058) @volexport-pandora(rw,no_root_squash)

do not cause the inconsistent behavior between mount -v and /proc/mounts 
(and it is mounted rw as expected on the client).

---++ A reply from NetApp had this info:

Starting with ONTAP 7.2.1 onward, ONTAP will display the "most
pessimistic" permissions to NFSv3 and NFSv4 clients. NFSv2 clients will
see permissions the same way as in previous releases of ONTAP, i.e. the
"most optimistic" permissions.

And mounting using NFS v2 (instead of v3) does give us the expected 
rw/rw consistency and ability.

---++ So now what?

Should the linux mount -v and cat /proc/mounts be consistent with what 
is actually happening?

Should netapp exports syntax handle a wildcard ro and a netgroup rw?

Comments and feedback welcome.

Thanks,

--Greg

-- 
----------------------------------------------------------------------
Greg Baker                                         512-602-3287 (work)
gregory.baker@amd.com                              512-602-6970 (fax)
5204 E. Ben White Blvd MS 625                      512-555-1212 (info)
Austin, TX 78741




-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
