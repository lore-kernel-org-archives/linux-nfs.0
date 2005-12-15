From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode bits during chown
Date: Thu, 15 Dec 2005 14:51:12 -0500
Message-ID: <20051215195112.GF8376@hmsreliant.homelinux.net>
References: <20051215130939.GA8111@hmsreliant.homelinux.net> <1134656087.7954.7.camel@lade.trondhjem.org> <20051215144945.GA8376@hmsreliant.homelinux.net> <1134658644.7954.13.camel@lade.trondhjem.org> <20051215163834.GB8376@hmsreliant.homelinux.net> <43A19E51.1060901@redhat.com> <1134667920.7944.14.camel@lade.trondhjem.org> <20051215181746.GC8376@hmsreliant.homelinux.net> <20051215194318.GD8376@hmsreliant.homelinux.net> <1134675975.7956.16.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net,
	neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emz8Q-0001XL-6P
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 11:51:26 -0800
Received: from ra.tuxdriver.com ([24.172.12.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emz8P-0007bD-Qa
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 11:51:26 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134675975.7956.16.camel@lade.trondhjem.org>
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

On Thu, Dec 15, 2005 at 02:46:15PM -0500, Trond Myklebust wrote:
> On Thu, 2005-12-15 at 14:43 -0500, Neil Horman wrote:
> 
> > Heres another alternative.  It removes the clearing of ATTR_KILL_SUID from
> > notify_change, so we can positively determine that the VFS intent in this case
> > was to issue a mode change for the purpose of clearing the SUID/SGID bits in the
> > file.  If we assume that the server will drop the s[g|u]id bits on our behalf,
> > then we can safely drop the mode modification in nfs_setattr, because we know
> > that was the only reason that the VFS was requesting that the mode be updated.
> 
> Why hack it like this instead of doing it right?
> 
Primarily because I don't really see it as a hack, but secondarily because I was
posting this at the same time that you were posting your suggestion :)

I'll work up another patch that attempts your suggested fix.

Regards
Neil

> Cheers,
>   Trond
> 
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
> for problems?  Stop!  Download the new AJAX search engine that makes
> searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
> http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
