From: Ion Badulescu <ionut@badula.org>
Subject: Re: nfs client using autofs v4
Date: Wed, 8 Jan 2003 20:17:13 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200301090117.h091HD426729@moisil.badula.org>
References: <Pine.GSO.4.50.0301081812460.2718-100000@bom.adc.idt.com>
Cc: linuxmanagers@linuxmanagers.org, NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: devnull@adc.idt.com
In-Reply-To: <Pine.GSO.4.50.0301081812460.2718-100000@bom.adc.idt.com>
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

On Wed, 8 Jan 2003 18:24:27 -0500 (EST), devnull@adc.idt.com wrote:
> 
> We would like to default all NFS mounts to use TCP and if not available
> use UDP. This way all mounts coming from Network Appliance will be TCP and
> the ones from the Linux Box will be UDP.
> 
> Does anyone know of a way of doing this.
> 
> Adding localoptions='nfsvers=3,tcp,udp' to the local autofs startup script
> does not work.
> 
> Maybe this is a compile-time option to autofs(i dont see one)

No, because autofs doesn't know anything about NFS. It simply calls the
external mount program with the arguments you gave it.

What you need is a mount program which can autodetect what the server
supports in terms of NFS service. I don't know of any such mount, though.
Your alternative is amd (www.am-utils.org), whose 6.1 version (now in late
beta) supports autofs mounts and which can do this autodetection and more.

Hope this helps,
Ion
[am-utils co-maintainer and primary developer of autofs support in amd]

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
