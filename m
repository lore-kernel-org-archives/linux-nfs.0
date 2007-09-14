From: Oliver Borm <borm@lfa.mw.tum.de>
Subject: NFSv3 with kerberos
Date: Sat, 15 Sep 2007 01:10:31 +0200
Message-ID: <46EB14E7.9070701@lfa.mw.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWKJe-0005Ka-QE
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 16:11:14 -0700
Received: from lfa-mail.lfa.mw.tu-muenchen.de ([129.187.66.5])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IWKJj-0008ID-4D
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 16:11:19 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I'm using gentoo linux with kernel from gentoo-sources-2.6.21-r4,
nfs-util-1.1.0, libnfsidmap-0.20  and librpcsecgss-0.14-r1.
When my exports on the server are:

 /local/tmp gss/krb5i(rw,async,subtree_check,insecure)
 /local/tmp 192.168.1.1/255.255.255.0(rw,async,subtree_check,insecure)

Then I can mount these shares with both NFSv3 and NFSv4 and Kerberos
Auth! But when the exports are only:

/foobar  gss/krb5i(rw,async,subtree_check,insecure)

Then I cannot mount these shares with NFSv3:

kiste-55 local # mount -t nfs -osec=krb5 192.168.1.21:/local/tmp test
mount: 192.168.1.21:/local/tmp failed, reason given by server:
Permission denied

And on the server a tail /var/log/messages gives:

Sep 15 00:36:12 kiste3-1 mountd[7543]: mount request from unknown host
192.168.1.55 for /local/tmp (/local/tmp)

Is this a bug or a feature? Is the problem here, with my settings? With
nfs4 the server knows the host! We're running an MS Win AD as the KDC
and DNS.
I want to use NFSv3 because the acl mapping is there supported better,
than wiht NFSv4! I have tested the tools on the CITI, but these were not
so good.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
