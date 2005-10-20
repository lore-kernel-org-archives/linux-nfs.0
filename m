From: "Weathers, Norman R." <Norman.R.Weathers@conocophillips.com>
Subject: Issue with parallel writes over NFS
Date: Thu, 20 Oct 2005 14:25:55 -0500
Message-ID: <D821697F08061F4FBB069FA1AAAA92370C4646@hoexmb7.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESg3H-0006F4-88
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 12:26:11 -0700
Received: from mailman1.ppco.com ([138.32.33.10])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1ESg3E-0005YT-La
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 12:26:11 -0700
Received: from bvlextrd03.conoco.net (bvlextrd03.conoco.net [138.32.33.146])
	by mailman1.ppco.com (Switch-3.1.7/Switch-3.1.7) with ESMTP id j9KJPxne000852
	for <nfs@lists.sourceforge.net>; Thu, 20 Oct 2005 14:25:59 -0500
Received: from bvlexbh3.conoco.net (bvlexbh3.conoco.net [138.32.45.44])
	by mail1.ppco.com (8.11.6+Sun/8.11.6) with ESMTP id j9KJPvu07948
	for <nfs@lists.sourceforge.net>; Thu, 20 Oct 2005 14:25:57 -0500 (CDT)
To: <nfs@lists.sourceforge.net>
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

Ok, this issue has to be prefaced with the usual "it worked before", but
here is an interesting situation.

(I will apologize in advance to the length of the email, but I am trying
to get all the information
that I can think of into this in advance).

We are having problems doing parallel writes from any of our 2.6 kernel
based linux systems.=20

The Low Down:

We have an in-house application that writes out in parallel to one file.
There can be anywhere from just
a few processes(10) to several(200) writing to the same file.  Each
process has its own discreet region
to write in, and they don't look at any other part of the file.

With 2.4 kernels, this application behaves very well.  It writes to the
files that it needs to, and never
has any corrupted or missing data.

We recently leased some new Opteron based systems, and so moved up some
nodes to the 2.6 kernel.
We were getting very good NFS response from our applications that are
parallel, but use a specific
IO node to communicate to the NFS world.  However, the parallel
application that does parallel writes
fails consistently with corrupted data or just plain missing data.

The Scenario:

My company has written an in-house test to mimic our application.  The
kicker is that the application
does not write on any kind of "nice page" boundaries.  For example, our
application could write 500 records to a
file, each record 5966*4 bytes, or 23864 bytes per record or table.  If
we have 50 processes writing
the records, each process tries to write 10 records at predefined
regions of 23864 bytes.  This fails.
We know because we pre-allocate the file and fill it with zeroes before
the run, and can see the
zeroes in the file with od after the program runs, and there shouldn't
be any zeroes. (Plus, we have
automated test programs that run after the parallel IO job to check the
file, and we are constantly
getting failures).  The failures do not happen in the same place every
time.=20

This is reproducible every time.  We have been able to reproduce this
with 10 processes (from 5 nodes)
writing to 1 file on 1 server.  Any extra processes (nodes) you throw
into the mix just makes
the situation even worse.

The strange thing is that this exact same code, test and actual
application, run extremely well behaved on
linux 2.4 kernel based distro's, and it doesn't seem to care if the code
uses multiples of 4k or some other
multiple, or something off the wall like 24000 bytes.

Kernels that have been tested:

32 and 64 bit from 2.6.7 (with NFS_ALL and -ck6 patches) all the way up
to 2.6.14-rc4-ck1 with NFS_ALL
patch plus the extra patch that I saw on the NFS list just recently from
Trond for some cache issue.

The servers involved are running RedHat 7.3 with 2.4.21 and 2.4.26
kernels, Fedora Core 3 with 2.6.11.7
vanilla kernels, and NetApp R200's.

Our exports are usually UDP to the older stuff and TCP to the newer
linux kernels with 32768 for read/write
block sizes.  It didn't matter if I made the client mount sync or not
(from the automounter), and for one final
set of tests, we even downed the read/write block size to 8k, but it
still didn't change the results, the writes
failed with missing data.

>From what I can hear through our internal grapevines, we may not be the
only company having
this issue.  Supposedly, some other companies are having similar issues
with parallel writes
over NFS.

Anything that we need to do to help, please let me know.  We have nodes
available to be able to test any=20
patches or debug info that you might need.

Thank you in advance.

Norman Weathers
Linux System Administrator
ConocoPhillips


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
