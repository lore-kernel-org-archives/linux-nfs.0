From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Help understanding error message?
Date: Tue, 28 Oct 2003 12:43:00 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16285.51620.467155.288641@notabene.cse.unsw.edu.au>
References: <3F984F27.1010806@noao.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AEJ8S-0006UN-00
	for <nfs@lists.sourceforge.net>; Mon, 27 Oct 2003 17:59:04 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AEIz5-0003AB-A7
	for nfs@lists.sourceforge.net; Mon, 27 Oct 2003 17:49:23 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <swampler@noao.edu>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 28 Oct 2003 12:43:00 +1100
To: Steve Wampler <swampler@noao.edu>
In-Reply-To: message from Steve Wampler on Thursday October 23
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

On Thursday October 23, swampler@noao.edu wrote:
> 
> System(s): 11 identical 2-cpu Althon boxes
>             RH 8.0, kernel 2.4.18-24.8.0/smp
>             nfs-utils-1.0.1-2
> 
> We're trying to track down a problem and need help
> understanding what an error message means (and what
> might be causing it...)
> 
> Background:  We have 11 identical Linux RH 8.0 boxes
> (dual-cpu Athlons).  One of them exports a filesystem
> via NFS to the other 10 (and to 5 other [different]
> Linux boxes as well).
> 
> Running a specific program on each of the 10 machines
> works sometimes and not others.  The machines on which
> it fails changes, but once it fails it continues to
> do so until we remount (unmount+mount, not with
> "-o remount") the NFS directory.  After the remount
> the program functions properly.


You aren't using "soft" mounts are you?  Please tell me you aren't.




> 
> Here is the error message (split to fit):
> 
> jboc-03:18> runwip
>     ../../../Bin/Linux/DHS/vsmWip:
>     error while loading shared libraries:
>     /opt/solis/devel/release/Lib/Linux/DHS/libprocess.so:
>     unexpected PLTreloc type 0xec
> 
> Both the program (vsmWip) and the offending shared
> library libprocess.so are located on the NFS-mounted FS.
> 
> I couldn't find a reference to 'unexpected PLTreloc'
> in mailing list archive search.
> 
> [Also, I've just discovered that ldd gives a segmentation
> fault:
> 
>    ->ldd vsmWip
>    /usr/bin/ldd: line 1: 15403 Segmentation fault
>        LD_TRACE_LOADED_OBJECTS=1 LD_WARN= LD_BIND_NOW=
>        LD_LIBRARY_VERSION=$verify_out LD_VERBOSE= "$file"
>    ->
> 
> if LD_LIBRARY_PATH is set to include the library
> directory on the NFS mount.  (Without that directory,
> ldd [correctly] simply identifies the shared libraries
> as missing.  ldd works properly in either case after
> a remount of the NFS mount.]
> 

I don't understand why you say "[correctly]".  

Can you copy the library file to /tmp when it is working, and then
copy again when it is failing, and do a 
   cmp -l
of the two files?

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: The SF.net Donation Program.
Do you like what SourceForge.net is doing for the Open
Source Community?  Make a contribution, and help us add new
features and functionality. Click here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
