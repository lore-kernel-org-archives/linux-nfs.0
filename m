From: "Jason D. McCormick" <jason@devrandom.org>
Subject: Linux NFSv4 Server and Client using Windows 2K3 AD/KDC
Date: Wed, 31 Oct 2007 22:26:00 -0400
Message-ID: <47293938.4010407@devrandom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InPkz-0004C3-Sk
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 19:26:06 -0700
Received: from cork.devrandom.org ([70.62.199.237])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InPl4-0001mW-7T
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 19:26:11 -0700
Received: from [172.17.17.5] (dynamic-acs-24-154-249-203.zoominternet.net
	[24.154.249.203])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by cork.devrandom.org (Postfix) with ESMTP id B127678247
	for <nfs@lists.sourceforge.net>; Wed, 31 Oct 2007 22:26:01 -0400 (EDT)
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

Hello All,

  I'm trying to setup a Linux NFSv4 server and client using Windows 2K3
AD as the KDC (Domain/Realm is AD.EXAMPLE.ORG).  I've successfully set
this up using MIT Kerberos before so the problems appear to be with the
Windows KDC portion of the setup.  I'm not sure this is supported with
Linux clients and servers -- most of the reading I see using Windows
KDCs is using NetApp filers.

  When attempting to mount the NFS export with '-o sec=krb5', I get a
timeout and an eventual failure to mount.  Running the client's rpc.gssd
in the foreground with verbose logging yields:

WARNING: Failed to create krb5 context for user with uid 0 for server
nfs-server.example.com
WARNING: Failed to create krb5 context for user with uid 0 with
credentials cache FILE:/tmp/krb5cc_machine_AD.EXAMPLE.COM for server
nfs-server.example.com
WARNING: Failed to create krb5 context for user with uid 0 with any
credentials cache for server nfs-server.example.com

Running the server's rpc.svcgssd in the foreground with verbose logging
yields:

handling null request
WARNING: gss_accept_sec_context failed
ERROR: GSS-API: error in handle_nullreq: gss_accept_sec_context():
Miscellaneous failure - Key table entry not found
WARNING: failed to write message

I see it claims there's no key table entry found, but from looking at
the message output in '-vvvv' it appears to be asking for
nfs/nfs-server.example.com@AD.EXAMPLE.COM like I would expect.  I have
the domain_realm mappings configured correctly ({,.}example.com =
AD.EXAMPLE.COM), the nfs/host principals stashed correctly in
/etc/krb5.keytab, they are using des-cbc-crc and I can use them
perfectly with a 'kinit -k nfs/host@REALM' command.  On the server, for
example:

# klist -k -e
Keytab name: FILE:/etc/krb5.keytab
KVNO Principal
---- -------------------------------------------------------------
   3 host/nfs-server.example.com@AD.EXAMPLE.COM (DES cbc mode with
     CRC-32)
   3 nfs/nfs-server.example.com@AD.EXAMPLE.COM (DES cbc mode with
     CRC-32)

I've read a lot of the usual places like Mike Eisler's blog and mailing
list and I've not found anything like what I'm experiencing (or else I'm
not searching on the right terms).

Anyone able to help?  I've tried a couple of different versions of
nfs-utils to see if there's an incompatibility and I've run into the
same problem with all of them.

Thanks.

-- Jason

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
