From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode bits
	during chown
Date: Thu, 15 Dec 2005 12:32:00 -0500
Message-ID: <1134667920.7944.14.camel@lade.trondhjem.org>
References: <20051215130939.GA8111@hmsreliant.homelinux.net>
	 <1134656087.7954.7.camel@lade.trondhjem.org>
	 <20051215144945.GA8376@hmsreliant.homelinux.net>
	 <1134658644.7954.13.camel@lade.trondhjem.org>
	 <20051215163834.GB8376@hmsreliant.homelinux.net>
	 <43A19E51.1060901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Horman <nhorman@tuxdriver.com>, nfs@lists.sourceforge.net,
	neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emwxy-0007kl-Hl
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 09:32:30 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emwxw-0004jm-Qi
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 09:32:30 -0800
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <43A19E51.1060901@redhat.com>
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

On Thu, 2005-12-15 at 11:48 -0500, Peter Staubach wrote:

> I don't think that it can be quite this easy.  I don't think that the 
> protocol
> requires that the server have this behavior, so, if the client requires it,
> then it will need to check to see whether the right thing happened and 
> if not,
> then make it happen.
> 
> Perhaps the right answer is a conditional second SETATTR operation to 
> correct
> the mode if it does not get set right when the uid/gid is changed.

That still allows for dangerous races in which client applications may
suddenly find themselves authorised to suid/sgid to the new uid/gid. Any
server that does this should probably be mounted using the nosuid mount
option and simply not be used for setuid/setgid applications.

As I see it, there are 2 possible options here:

 1) Rely on cached attributes and explicitly clear the suid/sgid mode
bit (which is what we do now).
 2) Rely on the server clearing the suid/sgid mode bit.

Trying to fix up the mode to be set inside the filesystem code is an
unacceptable practice since we cannot know who the caller is, or what
the intentions were.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
