From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode bits during
 chown
Date: Thu, 15 Dec 2005 11:48:17 -0500
Message-ID: <43A19E51.1060901@redhat.com>
References: <20051215130939.GA8111@hmsreliant.homelinux.net> <1134656087.7954.7.camel@lade.trondhjem.org> <20051215144945.GA8376@hmsreliant.homelinux.net> <1134658644.7954.13.camel@lade.trondhjem.org> <20051215163834.GB8376@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmwHY-0004XP-6Z
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 08:48:40 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EmwHV-0002qA-UV
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 08:48:40 -0800
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20051215163834.GB8376@hmsreliant.homelinux.net>
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

Neil Horman wrote:

>On Thu, Dec 15, 2005 at 09:57:24AM -0500, Trond Myklebust wrote:
>  
>
>>On Thu, 2005-12-15 at 09:49 -0500, Neil Horman wrote:
>>
>>    
>>
>>>I considered this, but I'm not sure thats the right way to go. It seems that the
>>>attribute structure can only set the mode bit, it has no way to represent a
>>>masking of bits.  So to set the mode, the VFS needs to know what the current
>>>mode flags are.  Since the sys_chown code path has no authoritative info on what
>>>the mode bits should be (like chmod does, where the user explicitly specifies
>>>the mode bits), notify_change has to rely on the current mode bits in
>>>inode->i_mode.  We could modify notify_change to not alter the mode bits at all
>>>and leave the ATTR_KILL_SUID flag in the ia_valid field for individual
>>>filesystems to deal with, but I'm not sure thats the better solution, as it
>>>would still leave NFS (and all other filesystems) with the responsibility of
>>>turning the s[u|g]id bits off.
>>>      
>>>
>>As far as an NFS client is concerned, we don't need to clear the
>>suid/sgid bits at all since the server will do it for us anyway. If the
>>VFS were to just send us the ATTR_UID/ATTR_GID fields, then we'd be
>>fine.
>>
>>As for local filesystems, they can be given a helper function that fixes
>>up the struct sattr to do the KILL_SUID thing.
>>
>>Cheers,
>>  Trond
>>
>>
>>
>>-------------------------------------------------------
>>This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
>>for problems?  Stop!  Download the new AJAX search engine that makes
>>searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
>>http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>    
>>
>
>Then this patch should work just as well (and save the overhead of both adding
>the extra getaddr call and the need to add a helper function to all the other
>supported file systems to kill the SUID bits that already happens in the VFS.
>

I don't think that it can be quite this easy.  I don't think that the 
protocol
requires that the server have this behavior, so, if the client requires it,
then it will need to check to see whether the right thing happened and 
if not,
then make it happen.

Perhaps the right answer is a conditional second SETATTR operation to 
correct
the mode if it does not get set right when the uid/gid is changed.

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
