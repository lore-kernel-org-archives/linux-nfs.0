From: Steve Wampler <swampler@noao.edu>
Subject: Re: Help understanding error message?
Date: Tue, 28 Oct 2003 06:54:20 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1067349260.22435.53.camel@weaver.tuc.noao.edu>
References: <3F984F27.1010806@noao.edu>
	 <16285.51620.467155.288641@notabene.cse.unsw.edu.au>
Reply-To: swampler@noao.edu
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AEUMa-0003Bf-00
	for <nfs@lists.sourceforge.net>; Tue, 28 Oct 2003 05:58:24 -0800
Received: from dns.noao.edu ([140.252.1.54] helo=noao.edu)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AEUIf-0005hr-ML
	for nfs@lists.sourceforge.net; Tue, 28 Oct 2003 05:54:21 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16285.51620.467155.288641@notabene.cse.unsw.edu.au>
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

On Mon, 2003-10-27 at 18:43, Neil Brown wrote:

> 
> You aren't using "soft" mounts are you?  Please tell me you aren't.

You're right, we're not.

> > [Also, I've just discovered that ldd gives a segmentation
> > fault:
> > 
> >    ->ldd vsmWip
> >    /usr/bin/ldd: line 1: 15403 Segmentation fault
> >        LD_TRACE_LOADED_OBJECTS=1 LD_WARN= LD_BIND_NOW=
> >        LD_LIBRARY_VERSION=$verify_out LD_VERBOSE= "$file"
> >    ->
> > 
> > if LD_LIBRARY_PATH is set to include the library
> > directory on the NFS mount.  (Without that directory,
> > ldd [correctly] simply identifies the shared libraries
> > as missing.  ldd works properly in either case after
> > a remount of the NFS mount.]
> > 
> 
> I don't understand why you say "[correctly]".  

Because not finding the shared libraries is the proper
behavior when LD_LIBRARY_PATH doesn't include the library dir
(as apposed to ldd seg-faulting when LD_LIBRARY_PATH does
include the library dir).

> Can you copy the library file to /tmp when it is working, and then
> copy again when it is failing, and do a 
>    cmp -l
> of the two files?

Thanks Neil - that's an excellent suggestion!  I'll see what the
produces.

-- 
Steve Wampler -- swampler@noao.edu
Quantum materiae materietur marmota monax si marmota
                    monax materiam possit materiari?


-------------------------------------------------------
This SF.net email is sponsored by: The SF.net Donation Program.
Do you like what SourceForge.net is doing for the Open
Source Community?  Make a contribution, and help us add new
features and functionality. Click here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
