From: "Paul Smith" <pausmith@nortelnetworks.com>
Subject: Re: NFS client write performance issue ... thoughts?
Date: 12 Jan 2004 12:30:24 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vpdrn08thy6n.fsf@lemming.engeast.baynetworks.com>
References: <75587E33AC778145AACCE1601EEABF420D49B2@kda-beexc-02.kda.kongsberg.com>
Reply-To: "Paul Smith" <pausmith@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Ag5tc-0003Ei-Nd
	for nfs@lists.sourceforge.net; Mon, 12 Jan 2004 09:30:36 -0800
Received: from zrtps0kp.nortelnetworks.com ([47.140.192.56])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ag5tc-0001DB-8w
	for nfs@lists.sourceforge.net; Mon, 12 Jan 2004 09:30:36 -0800
To: "Mikkelborg, Kjetil" <kjetil.mikkelborg@kongsberg.com>
In-Reply-To: <75587E33AC778145AACCE1601EEABF420D49B2@kda-beexc-02.kda.kongsberg.com>
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

%% "Mikkelborg, Kjetil" <kjetil.mikkelborg@kongsberg.com> writes:

Hi; can you please use normal quoting when replying to email?  If you
just include the entire original then type some comments in the middle
it's very difficult to find the comments you made.  Thanks!

  pds> ClearCase implements its own virtual filesystem type, and so is
  pds> heavily tied to specific kernels (the kernel module is not open
  pds> source of course :( ).  We basically can move to any kernel that
  pds> has been released as part of an official Red Hat release (say,
  pds> 2.4.20-8 from RH9 would work), but no other kernels can be used
  pds> (the ClearCase kernel module has checks on the sizes of various
  pds> kernel structures and won't load if they're not what it thinks
  pds> they should be--and since it's a filesystem it cares deeply about
  pds> structures that have tended to change a lot.  It won't even work
  pds> with vanilla kernel.org kernels of the same version.)

  mk> Actually It does not look like clearcase is checking for an exact
  mk> kernel version, it just depends on redhat hacks in the kernel (I
  mk> have no clue to which).

I didn't say it was checking for an exact kernel version.  I said it
checks the sizes of various kernel structures.  This is done dynamically
when the kernel module is loaded.

The way it works is this: the MVFS filesystem loadable module comes in
two parts: a precompiled part which you don't get the source to, and a
.c file which is a "wrapper".  The wrapper is recompiled against your
current kernel, headers, etc. then the two are linked together to form
the real mvfs.o module.  The wrapper provides a buffer against some
kinds of changes to the kernel.

But, the wrapper also examines about 30 different kernel data structures
and compares their sizes in your kernel against the ones expected in the
prebuilt .o file.  If they're different then the module won't load.
Some of these are pretty static, like "struct timeval", but some are
much more dynamic, like "struct file", etc.  For some structures they
care about the size of the whole structure, for some they care about the
offset into the structure of a given field.

  mk> But taking a 2.4.20-XX redhat kernel, and building it from SRPM
  mk> actually work. Furthermore, since you have the kernel in source
  mk> when building it from SRPM,

I never bother to build from the SRPM.  It's much more straightforward
to build from the kernel-source RPM.  YMMV of course.

  mk> you can add as many patches as you want, as long as these patches
  mk> does not screw with the same stuff clearcase mvfs relies on. I
  mk> managed to do some heavy modifying of a rh9 kernel SRPM, patch it
  mk> up to what level I needed + include support for diskless boot.

Yes; as long as you don't mess with the structures ClearCase cares
about, you win.  You can find the exact structures in question in the
STRUCT_CHECK_INIT macro in the mvfs_param.h file in the ClearCase
distribution directory.

-- 
-------------------------------------------------------------------------------
 Paul D. Smith <psmith@nortelnetworks.com>   HASMAT--HA Software Mthds & Tools
 "Please remain calm...I may be mad, but I am a professional." --Mad Scientist
-------------------------------------------------------------------------------
   These are my opinions---Nortel Networks takes no responsibility for them.


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
