From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: very strange nfs errors with nfsroot
Date: Wed, 25 Aug 2004 08:14:54 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412C2E5E.6070607@bio.ifi.lmu.de>
References: <412B5B3A.6070600@bio.ifi.lmu.de> <1093363691.5745.64.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bzr3l-0000vI-Fd
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 23:15:01 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Bzr3i-0003uC-SS
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 23:15:01 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1093363691.5745.64.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
>
> Is the /etc/local shared by all clients? If so, your script is buggy
> since it assumes that some other client cannot come in and ln before you
> do (this is a prime example of what is known as a "race condition").

No, for every client there is some /export/<ip>/ directory
with subdirectories etc/local, var/ etc...
So every client mounts just the subdirectories for its own
ip, so no race conditions can occur. The complete boot.nfsroot
script and the client-script works on completely separate
dirs for every client.
The errors can indeed be reproduced while I have only one
client up and running at all... (it's a test scenario
currently with a maximum of 5 clients).

> As for the ESTALE error. Again, if some other client is screwing with
> deleting and recreating the soft link on the server, then ESTALE is
> entirely expected behaviour. I suggest you read up on the NFS cache
> consistency promises.

Since this is not the case, it must be sth. happening just between
the server and the single client. And the only thing I could think
of that would cause "/dev/stdout" to be considered stale, was
the mount of /export/<ip>/dev over the /dev directory in the
read-only-mounted nfsroot...

Are there any debugging parameters I can set on the server
or the client side e.g. in /proc (I mount /proc for the
clients at the beginning of the boot.nfsroot script, so
it's there) to get some more details what's going wrong?

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
