From: Steve Wampler <swampler@noao.edu>
Subject: Help understanding error message?
Date: Thu, 23 Oct 2003 14:59:03 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F984F27.1010806@noao.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ACot7-00076K-00
	for <nfs@lists.sourceforge.net>; Thu, 23 Oct 2003 16:29:05 -0700
Received: from email.tuc.noao.edu ([140.252.1.54] helo=noao.edu)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1ACopZ-0004Po-7e
	for nfs@lists.sourceforge.net; Thu, 23 Oct 2003 16:25:25 -0700
Received: from weaver.tuc.noao.edu ([140.252.38.8] verified)
  by noao.edu (CommuniGate Pro SMTP 4.1.5)
  with ESMTP-TLS id 9276541 for nfs@lists.sourceforge.net; Thu, 23 Oct 2003 14:59:03 -0700
Received: from noao.edu (localhost.localdomain [127.0.0.1])
	by weaver.tuc.noao.edu (8.12.8/8.12.5) with ESMTP id h9NLx3ws004404
	for <nfs@lists.sourceforge.net>; Thu, 23 Oct 2003 14:59:03 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


System(s): 11 identical 2-cpu Althon boxes
            RH 8.0, kernel 2.4.18-24.8.0/smp
            nfs-utils-1.0.1-2

We're trying to track down a problem and need help
understanding what an error message means (and what
might be causing it...)

Background:  We have 11 identical Linux RH 8.0 boxes
(dual-cpu Athlons).  One of them exports a filesystem
via NFS to the other 10 (and to 5 other [different]
Linux boxes as well).

Running a specific program on each of the 10 machines
works sometimes and not others.  The machines on which
it fails changes, but once it fails it continues to
do so until we remount (unmount+mount, not with
"-o remount") the NFS directory.  After the remount
the program functions properly.

Here is the error message (split to fit):

jboc-03:18> runwip
    ../../../Bin/Linux/DHS/vsmWip:
    error while loading shared libraries:
    /opt/solis/devel/release/Lib/Linux/DHS/libprocess.so:
    unexpected PLTreloc type 0xec

Both the program (vsmWip) and the offending shared
library libprocess.so are located on the NFS-mounted FS.

I couldn't find a reference to 'unexpected PLTreloc'
in mailing list archive search.

[Also, I've just discovered that ldd gives a segmentation
fault:

   ->ldd vsmWip
   /usr/bin/ldd: line 1: 15403 Segmentation fault
       LD_TRACE_LOADED_OBJECTS=1 LD_WARN= LD_BIND_NOW=
       LD_LIBRARY_VERSION=$verify_out LD_VERBOSE= "$file"
   ->

if LD_LIBRARY_PATH is set to include the library
directory on the NFS mount.  (Without that directory,
ldd [correctly] simply identifies the shared libraries
as missing.  ldd works properly in either case after
a remount of the NFS mount.]


*ANY* help is appreciated.  Thanks in advance!

This is fairly new behavior, though we're now using the
system more heavily than previously.

-Steve



-------------------------------------------------------
This SF.net email is sponsored by: The SF.net Donation Program.
Do you like what SourceForge.net is doing for the Open
Source Community?  Make a contribution, and help us add new
features and functionality. Click here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
