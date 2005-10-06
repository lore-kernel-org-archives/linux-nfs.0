From: Ed L Cashin <ecashin@coraid.com>
Subject: Re: block dev minor > 255 and exporting fs
Date: Thu, 06 Oct 2005 12:38:58 -0400
Message-ID: <874q7u7g7x.fsf@coraid.com>
References: <87hdbvx41r.fsf@coraid.com>
	<17220.50476.651824.874256@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENZ7S-0005iJ-Ey
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 10:01:22 -0700
Received: from ns1.coraid.com
	([65.14.39.133] helo=coraid.com ident=none)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ENZ7R-0001DU-1C
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 10:01:22 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17220.50476.651824.874256@cse.unsw.edu.au> (Neil Brown's
 message of "Thu, 6 Oct 2005 16:33:16 +1000")
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

Neil Brown <neilb@suse.de> writes:

> On Wednesday October 5, ecashin@coraid.com wrote:
>> Hi.  I've noticed that an NFS mount times out when I export a
>> filesystem residing on a block device with a "large" minor number,
>> i.e. beyond the old limit of 255 from when there were only eight bits
>> for the minor number of devices.
>
> Hmmm.  it definitely shouldn't do that, but I'm not surprised.  knfsd
> has some fairly old-fashioned ideas about how device number work.
> I'll put it on my todo list to look at, 

Excellent!  I'd like to hear about what you find.

...
> but in the mean time there is
> another work around you could use that is slightly less awkward than
> making an 'md' device.
>
> If you would 'fsid=23', or some other number, as an option in
> /etc/exports, then it will use that number rather than the device
> number to identify the filesystem, and so it should work better.

Well I'll be!  That works great and is indeed much more convenient
than using md.  Thanks for the tip---I hadn't noticed fsid in the
exports manpage before.

-- 
  Ed L Cashin <ecashin@coraid.com>



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
