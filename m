From: Scott Leerssen <scott@leerssen.com>
Subject: Re: nfs root directory security
Date: 18 Jun 2003 10:27:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1055946469.16259.81.camel@sleerssen.racemi.com>
References: <Pine.LNX.4.44.0306181538500.5031-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from user-vc8ft6h.biz.mindspring.com ([216.135.244.209] helo=racemi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Sdtx-0008HJ-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 07:27:05 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0306181538500.5031-100000@kenzo.iwr.uni-heidelberg.de>
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

On Wed, 2003-06-18 at 09:55, Bogdan Costescu wrote:
> On 18 Jun 2003, Scott Leerssen wrote:
> 
> > Which is why we want NFS to stop a client from mounting anything above
> > the FS that it is supposed to have.
> 
> Yes, but isn't this achieved through lines like:
> 
> /home/client1	*.client1.com(rw)
> 
> If you want to export /home, you still have to specify all 
> domains/clients, like in:
> 
> /home	*.client.com(rw),*.client2.com(rw),*.client3.com(rw)
> 
> so there is not so much more work to do. Unless you use a wildcard like:
> 
> /home	*(rw)
> 
> which I certainly don't find secure.
> 
> > Not to mention it's pretty easy to spoof NFS by aliasing an interface to
> > another address;
> 
> That's why it's not advisable to use NFS on anything that you don't 
> control. For example, one easily overlooked security problem is having two 
> users with same UID on different systems - or allowing a computer not 
> controlled by you to mount such an export; the admin of this computer can 
> create users at will and be able to access your files...
> If you worry about aliasing of interfaces, you should look into statical
> ARP entries and/or netfilter.
> 
> > if you have your root mounted in /A/B/C/foo, then the curious will
> > attempt to mount /A/B/C to see what else is hanging around.
> 
> And that's where exporting per client will secure it: the client is not 
> allowed by the server to mount /A/B/C.
> 
> > The first mount point, the root FS, is given to the client via DHCP. 
> 
> The client can be given /A/B/C/123 instead of /A/B/C by the same automated 
> procedure. We do this here on our clusters (using PXELinux):
> 
>   append root=/dev/nfs nfsroot=192.168.7.203:/clients/%s ip=dhcp
> 
> However, because this is a closed network on which I have total control, I 
> have it exported like:
> 
> /clients	192.168.7.0/24(rw,no_root_squash)
> 
> where /clients contains directories called 192.168.7.1, 192.168.7.2, etc.

I agree with everything you say here, and in a controlled and fairly
unchanging environment with clients you trust, exporting to specific
clients is a perfectly acceptable solution.  All I'm suggesting is
adding an extra "layer of the onion" by restricting the ability to mount
read-restricted directories.  It gives us the ability to create
mountable filesystems for each server in a path that can not be
traversed by mounting higher level directories.

Imagine if the B and C paths of /A/B/C/root are cryptographically
generated names, and that C is different for every mount point, B is
different for every "repository", and A is simply an anchor in the root
of my NAS.  I can export my clients root filesystems as:

   /A 192.168.100.0/255.255.255.0(rw,no_root_squash,...)

If B and C are unmountable and unguessable (without a lot of failed and
obvious nfs mount attempts), I don't have to worry about anyone but the
intended client mounting its root filesystem (assuming the network is
safe from sniffing DHCP and mount requests).  Plus, I don't have to have
an entry for every single client.  I could, and that would buy me an
added bit of assurance, but I don't need one so it's much easier to
maintain hundreds of mount points.

Of course, there's a lot more to securing an NFS environment such as
this, particularly when you can't trust the clients to behave.  This
tweak just eases the burden of managing exports for hundreds (or
thousands) of clients on as many NAS as you can imagine.  The burden is
shifted to managing unreadable pathnames in the management software...
(sigh).

That's about all I have to add on this... feel free to use the patch or,
if you haven't already, delete it from your inbox.

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
