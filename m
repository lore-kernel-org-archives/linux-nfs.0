From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Testing tools
Date: Tue, 25 May 2004 09:21:42 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07C86@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSeh7-0000XQ-BN
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 09:22:25 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BSeh6-00084J-Tp
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 09:22:24 -0700
To: <vincent.roqueta@ext.bull.net>
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

hi vincent-

many thanks for gathering and publishing this information.

> Idealy we need to tests:
> -Robustness
> -performances
> -POSIX compliance
> -RFC Compliance
> -Interoperatiblity.

i think i know what you mean by most of these items, but i'd like to
understand what do you mean by "robustness" -- that a client or server
doesn't crash, or that it avoids crashing by degrading service?  or that
clients recover well when servers or networks crash?  or maybe that a
server works well in spite of file system errors or disk problems?  or
that a client works well in spite of network misbehavior?  i think it
could mean all of those things, and we should test for all of them.

i would like to add some other things to this list:

- scalability

  naturally you will test performance scalability as part of testing
performance.
  however, we also need to test such things as how many active and
*inactive*
  clients a server can support; whether certain configuration options
(such as
  the use of LDAP, kerberos, or large netgroups) will cause worse
performance;
  whether adding CPUs, memory, or more exports or mounts will hurt
performance;
  and of course any number of client areas that can be affected by
misconfiguration
  or large user count or the amount of resources available.

- security

  we need to have standard penetration testing as part of server
testing;
  code analysis (splint) on both the server and client; and in NFSv4,
the
  client callback server must be penetration tested.  we also need to do
  complete testing of whether privilege escalation exploits are exposed
on
  the client.  as you point out, multi-platform testing is critical, and
  we need code analysis to include how the various ports hold up as
endianess
  and the size of various data types changes.

- servicability

  do we have all the tools needed for an administrator to find and fix
  performance and reliability problems without much local knowlege about
  NFS itself?  is the trace message facility adequate?  is it easy to
  get good performance and stability of NFS with default options, right
  out of the box?  and so on.


and as we've discussed before, you can slice this group of tests in a
different way.  there are a set of tests that can easily be done as part
of patch acceptance -- ie check-in testing -- to make sure we do a
minimal amount of testing all the time.  then, there is a larger set of
more resource-expensive tests, like thorough performance regression
testing, that can be done regularly but not every night or against every
new patch.  and finally, application certification tests (like POSIX
conformance, Oracle and DB2 certification, and the like) can be done
once for a full Linux distribution because this kind of testing is
necessary but very expensive in terms of time and resources.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
