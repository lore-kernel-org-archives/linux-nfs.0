From: Ion Badulescu <ionut@badula.org>
Subject: Re: nfs client using autofs v4
Date: Thu, 9 Jan 2003 16:11:02 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0301091608340.15867-100000@guppy.limebrokerage.com>
References: <20030109204805.GA1042@questra.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: devnull@adc.idt.com, <linuxmanagers@linuxmanagers.org>,
   <NFS@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Scott Mcdermott <smcdermott@questra.com>
In-Reply-To: <20030109204805.GA1042@questra.com>
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

On Thu, 9 Jan 2003, Scott Mcdermott wrote:

> is there a way at runtime to detect if the client (running mount(8))
> supports a TCP mount? This would have to be tested first before trying
> to reach a server.

Only heuristically, based on the kernel version, and even that doesn't 
take into consideration the possibility that v3 support was not compiled 
into the kernel.

So amd tries a v3 mount (if the server supports it), and if that fails
with EINVAL then it retries the mount as v2/UDP. It's not ideal, but it
works.

Ion

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
