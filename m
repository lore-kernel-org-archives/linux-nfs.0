From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: nfs client using autofs v4
Date: Thu, 9 Jan 2003 15:48:05 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030109204805.GA1042@questra.com>
References: <Pine.GSO.4.50.0301081812460.2718-100000@bom.adc.idt.com> <200301090117.h091HD426729@moisil.badula.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devnull@adc.idt.com, linuxmanagers@linuxmanagers.org,
	NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <200301090117.h091HD426729@moisil.badula.org>
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

Ion Badulescu on Wed  8/01 20:17 -0500:
> > We would like to default all NFS mounts to use TCP and if not
> > available use UDP. This way all mounts coming from Network Appliance
> > will be TCP and the ones from the Linux Box will be UDP.
> 
> No, because autofs doesn't know anything about NFS. It simply calls the
> external mount program with the arguments you gave it.
> 
> What you need is a mount program which can autodetect what the server
> supports in terms of NFS service.

is there a way at runtime to detect if the client (running mount(8))
supports a TCP mount? This would have to be tested first before trying
to reach a server.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
