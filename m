From: Robert Myers <rmyers1400@attbi.com>
Subject: Re: NFS unmounts fail
Date: Sun, 22 Dec 2002 20:02:29 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E0660A5.9090607@attbi.com>
References: <3E06524D.1030608@routescience.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc53.attbi.com ([204.127.198.39])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18QGzJ-00039I-00
	for <nfs@lists.sourceforge.net>; Sun, 22 Dec 2002 17:02:33 -0800
To: Johan van Reijendam <jvanreij@routescience.com>
In-Reply-To: <3E06524D.1030608@routescience.com>
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

Johan van Reijendam wrote:

> Hi all,
>
> I have been unable to find the cause and a solution for this problem
>
> I am mounting NFS filesystems. Both the client and the server are 
> running Redhat 7.3. The problem is the following :
>
> I am able to mount a filesystem (automount or otherwise ) and can 
> browse that filesystem. When I pull out of that filesystem automount 
> will unmount it after a while and if manually mounted I am then able 
> to manually unmount it.
> However whenever I execute a binary from the mounted filesystem I am 
> no longer able to unmount that filesystem. The message I get is:
>
> umount: umount2: Device or resource busy
> umount: umount: /auto/packages/binaries: device is busy
>
> Neither lsof or fuser report any open files.

The most frequent cause of inexplicable "Device or resource is busy" 
messages when attempting an unmount has been that the device or some 
directory of the device is theoretically visible from Nautilus.  In 
those cases, closing the /mnts tab on the Nautilus tree and moving the 
view window to some other directory usually solves the problem.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
