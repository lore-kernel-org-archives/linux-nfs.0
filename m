From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re: Testing tools
Date: Thu, 27 May 2004 13:56:24 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200405271356.24106.vincent.roqueta@ext.bull.net>
References: <482A3FA0050D21419C269D13989C611302B07C86@lavender-fe.eng.netapp.com>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTJSY-0005lt-QV
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 04:54:06 -0700
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTJSW-0003Ij-LG
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 04:54:05 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07C86@lavender-fe.eng.netapp.com>
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

Le Mardi 25 Mai 2004 18:21, Lever, Charles a =E9crit :
> hi vincent-
>
> many thanks for gathering and publishing this information.
>
> > Idealy we need to tests:
> > -Robustness
> > -performances
> > -POSIX compliance
> > -RFC Compliance
> > -Interoperatiblity.
>
> i think i know what you mean by most of these items, but i'd like to
> understand what do you mean by "robustness" -- that a client or server
> doesn't crash, or that it avoids crashing by degrading service?  or that
> clients recover well when servers or networks crash?  or maybe that a
> server works well in spite of file system errors or disk problems?  or
> that a client works well in spite of network misbehavior?=20

=46or me, robustness is testing if the service run correctly (but with no=20
references to performances) even in hard condition. Testing if=20
=46or example : creating reccursively 100 directory within 100 directory 10=
0=20
times (and so 100^100 directory), copying very larges files, or a hight=20
number of very small files and verifying if there is no differences between=
=20
the original file and the copy.

An other kind of tests, is testing what append if the network is heavly=20
loaded, or if the load change quickly, or if the files operations are=20
correctly done using a large set of clients...

=46or example:

I used the LTP NFS suite (kernel 2.6.6 - CITI ALL 2.6.6 patchs:
1/ Making a big amount of directory works=20
2/copying/changin uid/guid on big/medium/small/very small files works

but fsstress on NFSv4 with 200 threads using the NFS shared directory=20
crashdown the NFS client and/or server... So there is a robustness problem =
=20
and I don't know where for now... but I suppose that's a pthread deadlock i=
n=20
the libc.


> i would like to add some other things to this list:
>
> - scalability
Sure. That is very important point.  The most part (all) performances tests=
=20
suites are capable of scalability testing.=20


>   naturally you will test performance scalability as part of testing
> performance.
>   however, we also need to test such things as how many active and
> *inactive*
>   clients a server can support; whether certain configuration options
> (such as
>   the use of LDAP, kerberos, or large netgroups) will cause worse
> performance;
Somes of the proposed tools are capable to emulate other protocols trafics,=
=20
inactives/actives servers.


>   whether adding CPUs, memory, or more exports or mounts will hurt
> performance;
>   and of course any number of client areas that can be affected by
> misconfiguration
>   or large user count or the amount of resources available.
Well... We need to setup a performance protocol that can be reproduce, so w=
e=20
admit the configuration _is_ good, and that no one except the test suite is=
=20
using the computer and the network : I am trying to have a reference test.=
=20
Operationals use of NFS may change from that.

We will try to mesure performances without hardware restriction, but we don=
't=20
plan to work deeply on hardware impacts on performances. (Mermory, cpu,=20
net...)=20



> - security
>
>   we need to have standard penetration testing as part of server
> testing;
>   code analysis (splint) on both the server and client; and in NFSv4,
> the
>   client callback server must be penetration tested.  we also need to do
>   complete testing of whether privilege escalation exploits are exposed
> on
>   the client.  as you point out, multi-platform testing is critical, and
>   we need code analysis to include how the various ports hold up as
> endianess
>   and the size of various data types changes.
True... and security is one of the big improvement of NFSv4!
 I am looking to see how we can do this, but I don't have enought security=
=20
background to really test that.


> - servicability
>
>   do we have all the tools needed for an administrator to find and fix
>   performance and reliability problems without much local knowlege about
>   NFS itself?  is the trace message facility adequate?  is it easy to
>   get good performance and stability of NFS with default options, right
>   out of the box?  and so on.
There are works in progress about administration : Frederic.Jolly@ext.bull.=
net=20
Tony.Reix@bull.net . But they need activity reports of the nfs server to=20
exploit them for the administrator.

>
> and as we've discussed before, you can slice this group of tests in a
> different way.  there are a set of tests that can easily be done as part
> of patch acceptance -- ie check-in testing -- to make sure we do a
> minimal amount of testing all the time.  then, there is a larger set of
> more resource-expensive tests, like thorough performance regression
> testing, that can be done regularly but not every night or against every
> new patch. =20
 Ok... I had modified the table to include this notion and is avalaible on =
the=20
website.
 I'm looking to complete table.


> and finally, application certification tests (like POSIX
> conformance, Oracle and DB2 certification, and the like) can be done
> once for a full Linux distribution because this kind of testing is
> necessary but very expensive in terms of time and resources.
True.

I was planning to tests
=2D> Robustness (June )
=2D> Performances (Next Robustness)
=2D> Compliances ... When NFSv4 will be ready.=20

Remind : filesystem POSIX conformances tests is NOT avalaible...=20

Cordialement,
Vincent ROQUETA





-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
