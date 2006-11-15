From: Open Source <opensource3141@yahoo.com>
Subject: "mount: File exists" when trying to mount a second krb5
	volume!
Date: Wed, 15 Nov 2006 14:39:55 -0800 (PST)
Message-ID: <20061115223955.6581.qmail@web58103.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkTQI-0006kP-A5
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 14:40:02 -0800
Received: from web58103.mail.re3.yahoo.com ([68.142.236.126])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GkTQH-0001R3-ON
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 14:40:03 -0800
To: nfs@lists.sourceforge.net
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

Hi,

I am having a very similar problem to the one reported
by Joachim Selke on the nfsv4 mailing list (see
http://linux-nfs.org/pipermail/nfsv4/2006-October/005226.html).
This might be out of the domain of the nfsv4 folks, so I'm
posting here now.

I recently upgraded my client and server side kernels
to 2.6.18.  I am unable to mount a second NFSv3+krb5
share after already mounting another one somewhere else
on the system.  For example,
"mount server:/export/home /net/home" works, but a
subsequent
"mount server:/export/data /net/data" returns

mount.nfs: File exists

I have no problems when performing the same with the
client running 2.6.17 and the server running 2.6.18.
I have been using NFSv3+krb5 for a long time with no
problems.  My exports file on the server looks like:

/export/data gss/krb5(secure,rw,sync,wdelay,hide,no_subtree_check,auth_nlm,root_squash,anonuid=65534,anongid=65534)
/export/data 192.168.0.0/24(secure,ro,sync,all_squash,anonuid=65534,anongid=65534)

which is the accepted way to export a NFSv3+krb5
volume since the non-krb5 export is used for mounting
and the krb5 export is used for actual file access.

(Also, my distribution is FC5 on the
client and the server except for a slight version upgrade
of util-linux and nfs-utils on the server to get around the
following problem:
http://linux-nfs.org/pipermail/nfsv4/2006-July/004694.html.)

Finally, I have done a wireshark dump and the initial part
of the RPC occurs with no problems but then the do_mount_syscall
function in mount.nfs:mount.c fails.  So I really think this is a
client side issue.  This guess is also supported by the fact
that the same 2.6.18 server works with a 2.6.17 client but
not a 2.6.18 client.

This is a very important issue for me so whatever advice
you can provide would be much appreciated.  I am happy
to provide more debugging information if you can tell me
what to turn on.  With my current installation I see *nothing*
in /var/log/messages on either the server or the client
when mount spits out its error.

Thanks in advance,
Paarvai






-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
