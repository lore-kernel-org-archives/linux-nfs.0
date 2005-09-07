From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Some code, and a question
Date: Wed, 07 Sep 2005 10:28:31 -0700
Message-ID: <1126114111.16701.33.camel@seki.nac.uci.edu>
References: <1126046397.3000.188.camel@seki.nac.uci.edu>
	 <20050907010219.GA14233@sgi.com>
	 <1126103821.16701.8.camel@seki.nac.uci.edu>  <431EFF78.6000709@redhat.com>
	 <1126112442.16701.17.camel@seki.nac.uci.edu>  <431F1FD5.4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Banks <gnb@sgi.com>, nfs@lists.sourceforge.net,
	strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ED3jO-00083W-3N
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 10:29:06 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ED3jN-00063t-Rz
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 10:29:06 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <431F1FD5.4@redhat.com>
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

On Wed, 2005-09-07 at 13:13 -0400, Peter Staubach wrote:
> Dan Stromberg wrote:
> 
> >On Wed, 2005-09-07 at 10:55 -0400, Peter Staubach wrote:
> >  
> >
> >>Dan Stromberg wrote:
> >>
> >>    
> >>
> >>>Here's the summary output from my script.  You may find it surprising.
> >>>It may have bugs, but so far it seems to be coming up with results that
> >>>one might not expect.  This was iterating rsize's and wsize's from 4K to
> >>>64K in steps of 1K.  BTW, this is from an AIX 5.1 host to a Solaris 9
> >>>host, but the script should run on nearly any unix or linux:
> >>>
> >>>      
> >>>
> >>Presumably you have made the configuration changes at least on the Solaris
> >>side, /etc/system or some such, to allow these systems to go all the way to
> >>a 64K transfer size?  Vanilla Solaris 9 won't do that.
> >>    
> >>
> >
> >No I haven't - great lead.  I'll see if I can google that up.  Or if you
> >have the incantation at your fingertips...
> >
> >  
> >
> 
> For Solaris, you might check out adding something like:
> 
>     set nfs:nfs3_max_transfer_size=1048576
>     set nfs:nfs4_max_transfer_size=1048576
> 
> to /etc/system and then reboot the system.  This will increase the maximum
> size of a transfer to 1M.  Alternately, you could use adb to patch a running
> system.  The command, "nfsstat -m", should tell you what the limits are for
> currently mounted file systems.  You will need to umount and mount any
> existing NFS mounted file systems in order for them to be able to use the
> new limits.

I'm giving the /etc/system stuff a shot right now.  I haven't adb'd a
Solaris kernel in ages - rather just stick with /etc/system when
possible.  Actually, last time I tried to adb a Solaris kernel, the
syntax that used to work fine, no longer did.

> >>What have you done to factor out the file system on the server?
> >>    
> >>
> >
> >Nothing.  Actually, I don't really want to in this case, because it's
> >the speed as seen by the enduser that I need to optimize, not the speed
> >of NFS alone.  That is, if there's something specific to the combination
> >of NFS and the underlying QFS filesystem, I don't want my benchmarking
> >to miss that.
> >
> 
> QFS, huh?  I hope that you have some QFS expertise to know how to tune it
> to match what you need.  It is notoriously difficult to tune, with many,
> many tunables.  It can be very high speed, but can also be very _not_,
> if you are not careful.

I set up our QFS.  I made the QFS transfer size the same as the
underlying stripe size in the underlying RAID 5's.  Is there more to it
than that?  I studied some QFS notes that a QFS instructor shared with
me, but I didn't see anything more about QFS tuning than that.

Thanks!




-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
