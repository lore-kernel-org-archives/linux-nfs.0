From: Olaf Kirch <okir@suse.de>
Subject: Re: statd simplified
Date: Tue, 3 Feb 2004 11:17:33 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040203101733.GB26315@suse.de>
References: <20040202140851.GH3145@suse.de> <401E8F6B.5040400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Anxho-0006oa-VT
	for nfs@lists.sourceforge.net; Tue, 03 Feb 2004 02:22:56 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Anxho-0000uz-HB
	for nfs@lists.sourceforge.net; Tue, 03 Feb 2004 02:22:56 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <401E8F6B.5040400@RedHat.com>
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

Hi,

On Mon, Feb 02, 2004 at 12:56:59PM -0500, Steve Dickson wrote:
> Letting /var/lib/nfs/sm grow uncontrollably (i.e. not using SM_UNMON to
> clean it up) may not be a good idea... Since users can't go in and clean 
> in up by hand
> (since they could be removing live state), there probably should be some
> way to cleaned up (and up to date)

Okay, I could add that. Calling unlink from kernel space is a bit of
a nuisance, but I'll try :)

> Currently when statd can not open the state file (in change_state()),  
> it dies
> which in turn causes lock requests to fail because that can't be monitored.
> In your kernel implementation, this failure seems to be ignored.  Since
> the failure would probably do to the sm directory not existing,  which
> also means state file will not able to be created,  it might make sense
> to fail the loading of lockd when this happens.

Agreed. Kernel statd just reads the file, however, it doesn't update
the state. That's done by rpc.statd -N.

I'll submit an updated patch later today or tomorrow.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
