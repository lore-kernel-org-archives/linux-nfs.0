From: Kyle Rose <krose+linuxnfs@krose.org>
Subject: Re: NFS server not responding
Date: Tue, 09 Dec 2003 15:09:22 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87ekvdpxcd.fsf@nausicaa.krose.org>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>
	<shsptfch1om.fsf@charged.uio.no> <3FCF70D9.1010808@RedHat.com>
	<shsr7zk5sw4.fsf@guts.uio.no> <3FCF86E9.2030300@RedHat.com>
	<1070571324.8472.2.camel@opus> <3FCFA606.8030809@RedHat.com>
	<87y8tsj7py.fsf@nausicaa.krose.org> <3FD626ED.1010100@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AToAl-0007ia-DO
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 12:09:31 -0800
Received: from dsl092-073-159.bos1.dsl.speakeasy.net ([66.92.73.159] helo=yupa.krose.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.24)
	id 1AToAk-0001nu-S1
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 12:09:31 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3FD626ED.1010100@RedHat.com> (Steve Dickson's message of "Tue,
 09 Dec 2003 14:47:57 -0500")
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

Steve Dickson <SteveD@redhat.com> writes:

> This is happening on a Fedora Core kernel, right?

No, this is a vanilla 2.6.0-test11.  Upon review of my email, I can't
believe I didn't mention the kernel version. :)

> If so, Could you send me the exact steps you do to cause this
> to happen....

Certainly.  Compile and reboot.  NFS comes up, after which SFS comes
up:

  /opt/sfs/bin/sfscd

Then, I log in as krose and

  cd music

where music is a symlink to
sfs/kushana.valley-of-wind.krose.org/music, the first two parts of
which are a symlink to
/sfs/@kushana.valley-of-wind.krose.org,jc72upywax7dsvd7rwpbvrfwpq4j2w7e.
So, in effect, I end up in
/sfs/@kushana.valley-of-wind.krose.org,jc72upywax7dsvd7rwpbvrfwpq4j2w7e/music.

Then I type ls, and get a segfault and an oops in dmesg.  (Sometimes,
it succeeds the first time, but always segfaults when I perform the
same steps a few minutes later.)  After this, NFS and/or SFS appear to
be wedged in a bad state, because future requests to SFS don't work.
Stopping SFS is a no-go, either.

I'm not really sure what kind of detail you're looking for, so please
feel free to be more specific if you want/need more information.

Cheers,
Kyle


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
