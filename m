From: Scott Leerssen <scott@leerssen.com>
Subject: Re: nfs root directory security
Date: 18 Jun 2003 08:36:42 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1055939802.28857.31.camel@lodge.leerssen.com>
References: <Pine.LNX.4.44.0306181123090.5031-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from granger.mail.mindspring.net ([207.69.200.148])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ScNc-0005C9-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 05:49:36 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0306181123090.5031-100000@kenzo.iwr.uni-heidelberg.de>
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

On Wed, 2003-06-18 at 05:30, Bogdan Costescu wrote:
> On Wed, 18 Jun 2003, Neil Brown wrote:
> 
> > So you want to hide the names from people who don't know them.
> 
> Security through obscurity rarely works...

Which is why we want NFS to stop a client from mounting anything above
the FS that it is supposed to have.

> 
> > Alternately just export the subdirectories rather than the parent.
> > Export different subdirectories to different clients.
> 
> I think that this is the only solution that makes sense. 

It's a function of how many, and often the mount points and the
addresses to which the mount points belong change.  Not to mention it's
pretty easy to spoof NFS by aliasing an interface to another address; if
you have your root mounted in /A/B/C/foo, then the curious will attempt
to mount /A/B/C to see what else is hanging around.

> Obviously you 
> need a script to take care of the /etc/exports file and upon any 
> modification run the 'exportfs' command. But you do this already, don't 
> you ? Or you maintain the hundreds or thousands client directories by 
> hand ???

It's automatic.

The first mount point, the root FS, is given to the client via DHCP. 
The client's fstab has been automatically populated by management
software to point to other stuff that it needs from the NAS, so when the
client boots, it mounts the FS that it has been given, plus any
additional FS that it wants/needs.

> The fact the the clients know what priviledges they have and can change 
> permissions sounds very strange to me from a security point of view...

The clients shouldn't be able to change anything, or get to anything
they are not supposed to.

Sorry... I didn't want to "advertise", as I think it's lame, but some
more context is required for this to make sense...  Take a look at
www.racemi.com, which is where I work and the reason for this simple and
quite effective change.  When combined with the other security features
of NFS, vlans, and smart switches, this gets us what we want to convince
customers that their filesystems are safe on shared storage.

For what it's worth, SunOS and BSD don't prevent mount access to
read-restricted directories either, so we had to tweak them as well for
those who desire slower NFS servers :)

-- 
Scott Leerssen <scott@leerssen.com>



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
