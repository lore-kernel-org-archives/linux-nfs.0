From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode	bits	during
 chown
Date: Thu, 15 Dec 2005 14:05:10 -0500
Message-ID: <43A1BE66.4000107@redhat.com>
References: <20051215130939.GA8111@hmsreliant.homelinux.net>	 <1134656087.7954.7.camel@lade.trondhjem.org>	 <20051215144945.GA8376@hmsreliant.homelinux.net>	 <1134658644.7954.13.camel@lade.trondhjem.org>	 <20051215163834.GB8376@hmsreliant.homelinux.net>	 <43A19E51.1060901@redhat.com> <1134667920.7944.14.camel@lade.trondhjem.org>	 <43A1B3CD.4050701@redhat.com> <1134672962.7956.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Neil Horman <nhorman@tuxdriver.com>, nfs@lists.sourceforge.net,
	neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmyPs-0006U3-Pl
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 11:05:24 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EmyPr-0004HQ-4d
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 11:05:24 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134672962.7956.9.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>On Thu, 2005-12-15 at 13:19 -0500, Peter Staubach wrote:
>  
>
>>It seems to me that there is a third option.  That would be to provide the
>>proper synchronization to prevent such races.  Any callers wishing to use
>>either the mode or owners of the file should have validated the attributes
>>first, and if there is such a setuid/setgid operation going on, then block
>>them until that operation has completed.  Perhaps something like the
>>revalidate hook can be used by the NFS client to synchronize things.
>>    
>>
>
>That also requires the VFS change to move the KILL_SUID/KILL_SGID stuff
>from notify_change() and into inode_setattr()/the filesystem code.
>
>  
>

Well, that isn't exactly what I had in mind, but I would need to look at
the implementation more in order to describe a design better.

>>We already know that it is not safe to combine changing the mode and the
>>uid or gid in a single NFS SETATTR request.  The server may or may not allow
>>the owners to be changed and so, may or may not perform the mode change.  In
>>fact, it is not terribly safe to combine changing the uid or gid with any
>>other attributes in a single call.  This is an unfortunate fact of life
>>when attempting to be interoperable across a large variety of platforms.
>>    
>>
>
>Yes, but that is why I'd argue that a server claiming to support
>suid/sgid mode bits had better have a _very_ good reason if it fails to
>clear them when a client changes the uid/gid.
>

The most common reason that I have seen is that the server may not be a 
POSIX
based server and may not emulate all of these semantics correctly.  
There are
times when the client has to interoperate with a "broken" server and for 
those
instances, we do not very aesthetic things in the client to make up for it.

    Thanx...

       ps


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
