From: devnull@adc.idt.com
Subject: nfs client using autofs v4
Date: Wed, 8 Jan 2003 18:24:27 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.50.0301081812460.2718-100000@bom.adc.idt.com>
Reply-To: devnull@adc.idt.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linuxmanagers@linuxmanagers.org
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

Dear Managers,

Apologies for the cross post.

We have some linux clients running on RH 7.3 with 2.4.18, and i am trying
to mount filesystems using NIS from a mixture of

Network Appliance boxes running v2 and v3 NFS(UDP and TCP)
Dell Box running Redhat 7.3 and 2.4.20 v2 and v3(UDP ONLY)

I am running autofsv4-pre10 from www.kernel.org(mainly to get /net).

We would like to default all NFS mounts to use TCP and if not available
use UDP. This way all mounts coming from Network Appliance will be TCP and
the ones from the Linux Box will be UDP.

Does anyone know of a way of doing this.

Adding localoptions='nfsvers=3,tcp,udp' to the local autofs startup script
does not work.

Maybe this is a compile-time option to autofs(i dont see one)

Worst case, i will need to make separate "auto_master" files for the Suns
and the Linux machines(i would like to avoid this)

Many thanks,

Best Regards.

/dev/null

devnull@adc.idt.com



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
