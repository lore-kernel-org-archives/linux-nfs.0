From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: nfs root directory security
Date: Wed, 18 Jun 2003 15:55:52 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0306181538500.5031-100000@kenzo.iwr.uni-heidelberg.de>
References: <1055939802.28857.31.camel@lodge.leerssen.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SdQ3-0001yk-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 06:56:11 -0700
To: Scott Leerssen <scott@leerssen.com>
In-Reply-To: <1055939802.28857.31.camel@lodge.leerssen.com>
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

On 18 Jun 2003, Scott Leerssen wrote:

> Which is why we want NFS to stop a client from mounting anything above
> the FS that it is supposed to have.

Yes, but isn't this achieved through lines like:

/home/client1	*.client1.com(rw)

If you want to export /home, you still have to specify all 
domains/clients, like in:

/home	*.client.com(rw),*.client2.com(rw),*.client3.com(rw)

so there is not so much more work to do. Unless you use a wildcard like:

/home	*(rw)

which I certainly don't find secure.

> Not to mention it's pretty easy to spoof NFS by aliasing an interface to
> another address;

That's why it's not advisable to use NFS on anything that you don't 
control. For example, one easily overlooked security problem is having two 
users with same UID on different systems - or allowing a computer not 
controlled by you to mount such an export; the admin of this computer can 
create users at will and be able to access your files...
If you worry about aliasing of interfaces, you should look into statical
ARP entries and/or netfilter.

> if you have your root mounted in /A/B/C/foo, then the curious will
> attempt to mount /A/B/C to see what else is hanging around.

And that's where exporting per client will secure it: the client is not 
allowed by the server to mount /A/B/C.

> The first mount point, the root FS, is given to the client via DHCP. 

The client can be given /A/B/C/123 instead of /A/B/C by the same automated 
procedure. We do this here on our clusters (using PXELinux):

  append root=/dev/nfs nfsroot=192.168.7.203:/clients/%s ip=dhcp

However, because this is a closed network on which I have total control, I 
have it exported like:

/clients	192.168.7.0/24(rw,no_root_squash)

where /clients contains directories called 192.168.7.1, 192.168.7.2, etc.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
