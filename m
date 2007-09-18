From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] export man page updated.
Date: Tue, 18 Sep 2007 14:01:23 -0400
Message-ID: <46F01273.2090607@RedHat.com>
References: <46EE9E73.1070002@RedHat.com> <46EEAF51.5010400@oracle.com>
	<46EFB157.4010508@RedHat.com> <46EFF364.7040003@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXhOA-000449-1x
	for nfs@lists.sourceforge.net; Tue, 18 Sep 2007 11:01:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IXhOC-0005RZ-Gi
	for nfs@lists.sourceforge.net; Tue, 18 Sep 2007 11:01:38 -0700
In-Reply-To: <46EFF364.7040003@oracle.com>
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



Chuck Lever wrote:
> 
> When I reply the attachment is discarded so I have to do a number of 
> steps to quote your patch that wouldn't be necessary if you had inlined 
> the patch.  The point of inlining patches rather than attaching them is 
> to allow others to quote the patch in their reply with no extra steps. 
> And there are tools to import inlined patches -- not sure if they work 
> for attachments.
> 
> It's a scalability thing when reviewers have to deal with dozens of 
> patches a day.
I agree.. Its just nobody mentioned they were having problems
with the way I was sending out patch... but its dully noted.


> 
> It's hard to say something like this is "a problem" since it is only a 
> man page.  But I like to leave things a little cleaner (more correct) 
> than when I found them.
True... Here is the updated patch:


commit 1cdab9665cf1a7bc2f9e51851f27eb5121b4be16
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Sep 18 13:53:25 2007 -0400

     Updated exportfs man to talk about /var/lib/nfs/etab
     instead of /var/lib/nfs/xtab

     Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/exportfs/exportfs.man b/utils/exportfs/exportfs.man
index 2bd8e31..9ca4ba3 100644
--- a/utils/exportfs/exportfs.man
+++ b/utils/exportfs/exportfs.man
@@ -22,14 +22,14 @@ The
  .B exportfs
  command is used to maintain the current table of exported file systems for
  NFS. This list is kept in a separate file named
-.BR /var/lib/nfs/xtab
+.BR /var/lib/nfs/etab
  which is read by
  .B mountd
  when a remote host requests access to mount a file tree, and parts of
  the list which are active are kept in the kernel's export table.
  .P
  Normally this
-.B xtab
+.B etab
  file is initialized with the list of all file systems named in
  .B /etc/exports
  by invoking
@@ -59,7 +59,7 @@ In the new mode,
  does not give any information to the kernel but only provides it to
  .B mountd
  through the
-.B /var/lib/nfs/xtab
+.B /var/lib/nfs/etab
  file.
  .B mountd
  will listen to requests from the kernel and will provide information
@@ -69,7 +69,7 @@ In the legacy mode,
  any export requests which identify a specific host (rather than a
  subnet or netgroup etc) are entered directly into the kernel's export
  table as well as being written to
-.BR /var/lib/nfs/xtab .
+.BR /var/lib/nfs/etab .
  Further, any mount points listed in
  .B /var/lib/nfs/rmtab
  which match a non host-specific export request will cause an
@@ -93,8 +93,10 @@ file, so that only default options and options given 
on the command
  line are used.
  .TP
  .B -r
-Reexport all directories. It synchronizes /var/lib/nfs/xtab
-with /etc/exports. It removes entries in /var/lib/nfs/xtab
+Reexport all directories. It synchronizes
+.B /var/lib/nfs/etab
+with /etc/exports. It removes entries in
+.B /var/lib/nfs/etab
  which are deleted from /etc/exports, and remove any entries from the
  kernel export table which are no longer valid.
  .TP
@@ -120,7 +122,7 @@ entries to the export table.  When using
  all directories in
  .B exports(5)
  are added to
-.B xtab
+.B etab
  and the resulting list is pushed into the kernel.
  .P
  The
@@ -152,7 +154,7 @@ directory.
  Modifications of the kernel export table used by
  .B nfsd(8)
  take place immediately after parsing the command line and updating the
-.B xtab
+.B etab
  file.
  .P
  The default export options are
@@ -163,14 +165,14 @@ The third synopsis shows how to unexported a 
currently exported directory.
  When using
  .BR "exportfs -ua" ,
  all entries listed in
-.B xtab
+.B etab
  are removed from the kernel export tables, and the file is cleared. This
  effectively shuts down all NFS activity.
  .P
  To remove individual export entries, one can specify a
  .I host:/path
  pair. This deletes the specified entry from
-.B xtab
+.B etab
  and removes the corresponding kernel entry (if any).
  .P
  .\" -------------------- Dumping the Export Table -----------------
@@ -186,7 +188,7 @@ option, the list of flags pertaining to each export 
are shown in addition.
  The following adds all directories listed in
  .B /etc/exports
  to
-.B /var/lib/nfs/xtab
+.B /var/lib/nfs/etab
  and pushes the resulting export entries into the kernel:
  .P
  .nf

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
