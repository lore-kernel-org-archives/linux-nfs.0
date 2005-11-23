From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [Fwd: [Bug 5644] New: NFS v3 TCP 3-way handshake incorrect,
 iptables blocks access]
Date: Wed, 23 Nov 2005 12:42:11 -0500
Message-ID: <1132767731.8016.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ca5NVEcVbG2IQP6NP9/j"
Cc: nfs@lists.sourceforge.net, Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eeydp-0004Bv-Oq
	for nfs@lists.sourceforge.net; Wed, 23 Nov 2005 09:42:45 -0800
Received: from pat.uio.no ([129.240.130.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Eeydg-0003uS-3i
	for nfs@lists.sourceforge.net; Wed, 23 Nov 2005 09:42:45 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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


--=-ca5NVEcVbG2IQP6NP9/j
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Neil,

  Can you see any reason why I shouldn't shunt this bug over to the
networking folks?

Cheers,
  Trond

--=-ca5NVEcVbG2IQP6NP9/j
Content-Disposition: inline
Content-Description: Forwarded message - [Bug 5644] New: NFS v3 TCP 3-way
	handshake incorrect, iptables blocks access
Content-Type: message/rfc822

Return-Path: <www@osdl.org>
Received: from mail-imap3.uio.no ([unix socket]) by mail-imap3.uio.no
	(Cyrus v2.2.10) with LMTPA; Wed, 23 Nov 2005 17:04:06 +0100
X-Sieve: CMU Sieve 2.2
Delivery-date: Wed, 23 Nov 2005 17:04:06 +0100
Received: from mail-mx2.uio.no ([129.240.10.30]) by mail-imap3.uio.no with
	esmtp (Exim 4.43) id 1Eex6M-0001jD-QY for trond.myklebust@fys.uio.no; Wed,
	23 Nov 2005 17:04:06 +0100
Received: from smtp.osdl.org ([65.172.181.4]) by mail-mx2.uio.no with
	esmtps (TLSv1:DES-CBC3-SHA:168) (Exim 4.43) id 1Eex6D-0005HH-3p for
	trond.myklebust@fys.uio.no; Wed, 23 Nov 2005 17:03:57 +0100
Received: from fire-2.osdl.org (localhost [127.0.0.1]) by smtp.osdl.org
	(8.12.8/8.12.8) with ESMTP id jANG3rnO026282 (version=TLSv1/SSLv3
	cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO) for
	<trond.myklebust@fys.uio.no>; Wed, 23 Nov 2005 08:03:53 -0800
Received: (from www@localhost) by fire-2.osdl.org (8.12.8/8.12.5/Submit) id
	jANG3qDT026280; Wed, 23 Nov 2005 08:03:52 -0800
Date: Wed, 23 Nov 2005 08:03:52 -0800
Message-Id: <200511231603.jANG3qDT026280@fire-2.osdl.org>
From: bugme-daemon@bugzilla.kernel.org
To: trond.myklebust@fys.uio.no
Subject: [Bug 5644] New: NFS v3 TCP 3-way handshake incorrect, iptables
	blocks access
X-Bugzilla-Reason: AssignedTo
X-Bugzilla-Category: File System
X-Bugzilla-Component: NFS
Received-SPF: pass (localhost is always allowed.)
X-Spam-Status: No, hits=1.088 required=5 tests=NO_REAL_NAME
X-Spam-Level: *
X-Spam-Checker-Version: SpamAssassin 2.63-osdl_revision__1.56__
X-MIMEDefang-Filter: osdl$Revision: 1.127 $
X-Scanned-By: MIMEDefang 2.36
X-MailScanner-Information: This message has been scanned for viruses/spam.
	Contact postmaster@uio.no if you have questions about this scanning
X-UiO-MailScanner: No virus found
X-UiO-Spam-info: not spam, SpamAssassin (score=0.178, required 12,
	autolearn=disabled, NO_REAL_NAME 0.18)
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

http://bugzilla.kernel.org/show_bug.cgi?id=5644

           Summary: NFS v3 TCP 3-way handshake incorrect, iptables blocks
                    access
    Kernel Version: 2.6.14
            Status: NEW
          Severity: blocking
             Owner: trond.myklebust@fys.uio.no
         Submitter: jl-icase@comcast.net


Most recent kernel where this bug did not occur:
Distribution: Can't remember, possibly FC2.
Hardware Environment:
Software Environment:
Problem Description:

Steps to reproduce:
1. Boot NFS v3 TCP client running iptables & mount NFS filesystem
2. Do a normal NFS client reboot & try mounting the same filesystem again
3. Experience intermittent failure to read superblock

The cause of this problem is NFS server's improper response to SYN packet sent
by the client.  This occurs *after* successful client authorization, when the
client tries to open the connection (i.e. sends SYN to the server's nfs port) to
read the superblock.  The server (sometimes) responds with a pure ACK without
the SYN bit set.  This is blocked by iptables -- thus, mount fails with a "could
not read superblock" message.

Here is an excerpt from ethereal log:

      3 0.021733    client           SERVER           TCP      800 > nfs [SYN]
Seq=0 Ack=0 Win=5840 Len=0 MSS=1460 TSV=24095 TSER=0 WS=2
      4 0.021846    SERVER           client           TCP      nfs > 800 [ACK]
Seq=9138391 Ack=3580883479 Win=16022 Len=0 TSV=244936050 TSER=1149400
      5 0.021864    client           SERVER           ICMP     Destination
unreachable (Host administratively prohibited)

The above problem occurs with a very simple default+ssh iptables configuration.
 Disabling iptables on the client makes the problem go away.  Even with iptables
active, there is no problem when nfsd responds with a proper [SYN,ACK] instead
of just pure ACK (this happens intermittently after the client reboot).

Please fix nfsd so that it reliably responds to SYN packets with proper
[SYN,ACK] packets instead of just ACK packets.  Apparently, nfsd state doesn't
get properly reset on client reboots.  Other people have reported autofs
failures which may be related (e.g. on remounts).

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.

--=-ca5NVEcVbG2IQP6NP9/j--



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
